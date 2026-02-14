<script setup>
import { useForm, Head, Link, router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    equipment: Object,    // Paginated Fleet items (is_attachment: 0)
    depoSpares: Array,    // Array of Warehouse items (is_attachment: 1)
    allRigs: Array,       // List for the "Link to Rig" dropdown
    categories: Array,
    brands: Array,
    sites: Array,
    employees: Array      // List of mechanics for logs
});

// --- STATE ---
const activeTab = ref('fleet');
const showAddModal = ref(false);
const showLinkModal = ref(false);
const editingItem = ref(null);
const showLogsModal = ref(false);
const showLogForm = ref(false);
const selectedItem = ref(null);
const linkingSpare = ref(null);
const searchQuery = ref('');

// --- FORMS ---
const addForm = useForm({
    name: '', serial_number: '', category_id: '', brand_id: '',
    current_site_id: '', status: 'Working', is_attachment: 0
});

const editForm = useForm({ name: '', serial_number: '', status: '' });
const linkForm = useForm({ spare_id: '', parent_id: '' });

const logForm = useForm({
    equipment_id: '',
    mechanic_id: '',
    service_date: new Date().toISOString().split('T')[0],
    running_hours: '',
    service_type: '',
    parts_replaced: '',
});

// --- DATA FILTERING ---
const filteredData = computed(() => {
    // Fleet uses .data because it is paginated; Depo is a direct array
    const dataSource = activeTab.value === 'fleet' ? props.equipment.data : props.depoSpares;
    if (!dataSource) return [];
    if (!searchQuery.value) return dataSource;

    return dataSource.filter(item =>
        item.name?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        item.serial_number?.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

// --- METHODS ---
const openHistory = (item) => {
    selectedItem.value = item;
    showLogsModal.value = true;
    showLogForm.value = false;
};

const submitLog = () => {
    logForm.equipment_id = selectedItem.value.id;
    logForm.post(route('inventory.service-logs.store'), {
        preserveScroll: true,
        onSuccess: () => {
            // Re-sync local selectedItem with the refreshed paginated prop
            const updatedEquipment = props.equipment.data.find(e => e.id === selectedItem.value.id);
            if (updatedEquipment) {
                selectedItem.value = updatedEquipment;
            }
            logForm.reset(['running_hours', 'service_type', 'parts_replaced', 'mechanic_id']);
            showLogForm.value = false;
        }
    });
};

const openLinkModal = (spare) => {
    linkingSpare.value = spare;
    linkForm.spare_id = spare.id;
    linkForm.parent_id = '';
    showLinkModal.value = true;
};

const submitLink = () => {
    // Matches Route::post('/inventory/link-spare') or Route::put
    linkForm.post('/inventory/link-spare', {
        preserveScroll: true,
        onSuccess: () => {
            showLinkModal.value = false;
            linkForm.reset();
        }
    });
};

const unlinkSpare = (spareId) => {
    if (confirm('Move this item back to the Warehouse?')) {
        router.post(`/inventory/unlink-spare/${spareId}`, {}, {
            preserveScroll: true,
            onSuccess: () => {
                const updatedParent = props.equipment.data.find(i => i.id === selectedItem.value.id);
                if(updatedParent) selectedItem.value = updatedParent;
            }
        });
    }
};

const handleTransfer = (id, event) => {
    const siteId = event.target.value;
    if (!siteId) return;
    router.post('/inventory/transfer', {
        equipment_id: id, to_site_id: siteId,
        transfer_date: new Date().toISOString().split('T')[0]
    });
};

const getStatusBadge = (status) => {
    const map = { 'Working': 'bg-green-100 text-green-700', 'In Stock': 'bg-blue-100 text-blue-700' };
    return map[status] || 'bg-gray-100 text-gray-700';
};
</script>

<template>
    <Head title="Fleet & Warehouse" />

    <div class="min-h-screen bg-gray-50 p-4 md:p-8 text-gray-800">
        <div class="max-w-7xl mx-auto">
            <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-200 mb-6 flex flex-col md:flex-row justify-between items-center gap-4">
                <div>
                    <h1 class="text-2xl font-black uppercase italic text-slate-900">LPC Inventory</h1>
                    <div class="flex gap-2 mt-4 bg-gray-100 p-1 rounded-2xl border">
                        <button @click="activeTab = 'fleet'" :class="activeTab === 'fleet' ? 'bg-white shadow-sm text-indigo-600' : 'text-gray-500'" class="px-6 py-2 rounded-xl text-[10px] font-black uppercase transition-all">
                            Fleet ({{ equipment.total }})
                        </button>
                        <button @click="activeTab = 'warehouse'" :class="activeTab === 'warehouse' ? 'bg-white shadow-sm text-indigo-600' : 'text-gray-500'" class="px-6 py-2 rounded-xl text-[10px] font-black uppercase transition-all">
                            Depo ({{ depoSpares.length }})
                        </button>
                    </div>
                </div>
                <div class="flex gap-2 w-full md:w-auto">
                    <input v-model="searchQuery" placeholder="Search..." class="rounded-xl border-gray-200 text-sm px-4 flex-1 md:w-64" />
                    <button @click="showAddModal = true" class="bg-emerald-600 text-white px-6 py-2 rounded-xl font-black text-[10px] uppercase shadow-lg">+ Add New</button>
                </div>
            </div>

            <div class="bg-white rounded-3xl shadow-sm border border-gray-200 overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-gray-50 border-b">
                        <tr class="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            <th class="px-6 py-5">Item Details</th>
                            <th class="px-6 py-5">Current Site</th>
                            <th class="px-6 py-5">Status</th>
                            <th class="px-6 py-5 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 text-sm">
                        <tr v-for="item in filteredData" :key="item.id" :class="{'bg-gray-50/50': item.parent_id}">
                            <td class="px-6 py-4">
                                <div class="font-bold text-gray-800">{{ item.name }}</div>
                                <div class="text-[10px] font-mono text-indigo-500 font-bold uppercase tracking-tighter">{{ item.serial_number }}</div>

                                <div v-if="activeTab === 'warehouse' && item.parent" class="mt-1">
                                    <span class="text-[8px] bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full font-black uppercase italic">
                                        Attached to: {{ item.parent.name }}
                                    </span>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <template v-if="item.parent_id">
                                    <span class="text-[9px] font-bold text-gray-400 uppercase italic">Locked by Rig</span>
                                </template>
                                <template v-else>
                                    <span class="text-gray-600 font-bold text-xs block mb-1">{{ item.current_site?.location_name || 'Main Depo' }}</span>
                                    <select @change="handleTransfer(item.id, $event)" class="text-[9px] border-none bg-gray-100 rounded-lg p-1 w-28 cursor-pointer">
                                        <option value="">Move To...</option>
                                        <option v-for="site in sites" :key="site.id" :value="site.id">{{ site.location_name }}</option>
                                    </select>
                                </template>
                            </td>
                            <td class="px-6 py-4">
                                <span :class="getStatusBadge(item.status)" class="px-3 py-1 rounded-full text-[9px] font-black border uppercase">
                                    {{ item.status }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-right space-x-2">
                                <button @click="openHistory(item)" class="text-indigo-600 font-black text-[10px] uppercase underline">History</button>
                                <button v-if="activeTab === 'warehouse' && !item.parent_id" @click="openLinkModal(item)" class="text-emerald-600 font-black text-[10px] uppercase underline">Link to Rig</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div v-if="activeTab === 'fleet' && equipment.links.length > 3" class="flex justify-center gap-1 py-8">
                <Link v-for="(link, k) in equipment.links" :key="k" :href="link.url || '#'" v-html="link.label"
                      class="px-4 py-2 rounded-xl text-xs font-bold border transition-all"
                      :class="[link.active ? 'bg-indigo-600 text-white shadow-md' : 'bg-white text-gray-600 hover:bg-gray-50', !link.url ? 'opacity-30 cursor-not-allowed' : '']" />
            </div>
        </div>

        <div v-if="showLinkModal && linkingSpare" class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-[2rem] shadow-2xl w-full max-w-md p-8">
                <div class="mb-6">
                    <h3 class="text-xl font-black uppercase italic">Link to Machine</h3>
                    <p class="text-xs text-gray-500">Attaching <span class="text-indigo-600 font-bold">{{ linkingSpare.name }}</span> to a parent rig.</p>
                </div>
                <form @submit.prevent="submitLink" class="space-y-4">
                    <div>
                        <label class="text-[10px] font-black uppercase text-gray-400 ml-2">Select Target Rig</label>
                        <select v-model="linkForm.parent_id" class="w-full border-gray-200 rounded-2xl text-sm" required>
                            <option value="">Choose a machine...</option>
                            <option v-for="rig in allRigs" :key="rig.id" :value="rig.id">{{ rig.name }} ({{ rig.serial_number }})</option>
                        </select>
                    </div>
                    <div class="flex gap-3 pt-4">
                        <button type="button" @click="showLinkModal = false" class="flex-1 py-4 bg-gray-100 text-gray-500 rounded-2xl font-black uppercase text-[10px]">Cancel</button>
                        <button type="submit" class="flex-1 py-4 bg-indigo-600 text-white rounded-2xl font-black uppercase text-[10px]" :disabled="linkForm.processing">Confirm Link</button>
                    </div>
                </form>
            </div>
        </div>

        <div v-if="showLogsModal && selectedItem" class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-[2rem] shadow-2xl w-full max-w-2xl max-h-[85vh] overflow-y-auto p-8">
                <div class="flex justify-between items-center mb-8 border-b pb-4">
                    <div>
                        <h3 class="text-xl font-black uppercase italic text-gray-900">{{ selectedItem.name }}</h3>
                        <p class="text-[10px] font-mono text-indigo-500 font-bold uppercase">S/N: {{ selectedItem.serial_number }}</p>
                    </div>
                    <button @click="showLogsModal = false" class="text-3xl font-light">&times;</button>
                </div>

                <div v-if="selectedItem.spares?.length > 0" class="mb-8">
                    <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4 italic">Linked Spares</h4>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <div v-for="s in selectedItem.spares" :key="s.id" class="p-4 bg-indigo-50 border border-indigo-100 rounded-2xl flex justify-between items-center">
                            <div>
                                <p class="font-bold text-xs">{{ s.name }}</p>
                                <p class="text-[9px] font-mono text-indigo-400 font-bold uppercase">{{ s.serial_number }}</p>
                            </div>
                            <button @click="unlinkSpare(s.id)" class="text-[9px] font-black text-red-500 uppercase underline">Unlink</button>
                        </div>
                    </div>
                </div>

                <div class="mb-6">
                    <div class="flex justify-between items-center mb-4">
                        <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest italic">Maintenance Log</h4>
                        <button @click="showLogForm = !showLogForm" class="bg-indigo-600 text-white px-3 py-1 rounded-lg text-[9px] font-black uppercase">
                            {{ showLogForm ? 'Cancel' : '+ Add Record' }}
                        </button>
                    </div>

                    <div v-if="showLogForm" class="bg-gray-50 p-6 rounded-3xl border border-dashed border-indigo-200 mb-6">
                        <form @submit.prevent="submitLog" class="grid grid-cols-2 gap-4">
                            <div class="col-span-1">
                                <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Service Date</label>
                                <input v-model="logForm.service_date" type="date" class="w-full border-gray-200 rounded-xl text-xs" required />
                            </div>
                            <div class="col-span-1">
                                <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Mechanic</label>
                                <select v-model="logForm.mechanic_id" class="w-full border-gray-200 rounded-xl text-xs" required>
                                    <option value="">Select Mechanic</option>
                                    <option v-for="emp in employees" :key="emp.id" :value="emp.id">{{ emp.name }}</option>
                                </select>
                            </div>
                            <div class="col-span-1">
                                <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Running Hours</label>
                                <input v-model="logForm.running_hours" type="number" step="0.1" class="w-full border-gray-200 rounded-xl text-xs" required />
                            </div>
                            <div class="col-span-2">
                                <input v-model="logForm.service_type" placeholder="Service Type (e.g., 500H Service)" class="w-full border-gray-200 rounded-xl text-xs" required />
                            </div>
                            <div class="col-span-2">
                                <textarea v-model="logForm.parts_replaced" placeholder="Details/Parts Replaced..." class="w-full border-gray-200 rounded-xl text-xs" rows="2"></textarea>
                            </div>
                            <button type="submit" class="col-span-2 py-3 bg-indigo-600 text-white rounded-xl font-black uppercase text-[10px]" :disabled="logForm.processing">
                                {{ logForm.processing ? 'Saving...' : 'Save Record' }}
                            </button>
                        </form>
                    </div>

                    <div v-if="(selectedItem.maintenance_logs || selectedItem.maintenanceLogs)?.length > 0" class="space-y-4">
                        <div v-for="log in (selectedItem.maintenance_logs || selectedItem.maintenanceLogs)" :key="log.id" class="p-5 border rounded-3xl bg-gray-50">
                            <div class="flex justify-between font-black text-[10px] mb-2 text-gray-400 uppercase tracking-widest">
                                <span>{{ log.service_date }}</span>
                                <span class="text-emerald-500">{{ log.running_hours }} HRS</span>
                            </div>
                            <p class="font-black text-gray-800 text-sm uppercase mb-1">{{ log.service_type }}</p>
                            <p class="text-xs text-gray-500 leading-relaxed">{{ log.parts_replaced }}</p>
                            <p v-if="log.mechanic" class="text-[9px] font-bold text-indigo-400 mt-2 uppercase italic">By: {{ log.mechanic.name }} ({{ log.mechanic.designation }})</p>
                        </div>
                    </div>
                    <p v-else class="text-xs italic text-gray-400 text-center py-8">No service records available.</p>
                </div>
            </div>
        </div>
    </div>
</template>
