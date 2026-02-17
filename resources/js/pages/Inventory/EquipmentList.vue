<script setup>
import { useForm, Head, Link, router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    equipment: Object,    // Paginated Fleet items (is_attachment: 0)
    depoSpares: Array,    // Array of Warehouse items (is_attachment: 1)
    allRigs: Array,       // List for the "Link to Rig" dropdown
    sites: Array,
    employees: Array,     // List of mechanics for logs
    categories: Array,
    brands: Array
});

// --- STATE ---
const activeTab = ref('fleet');
const showAddModal = ref(false); // Controlled by the new button
const showLinkModal = ref(false);
const showLogsModal = ref(false);
const showLogForm = ref(false);
const selectedItem = ref(null);
const linkingSpare = ref(null);
const searchQuery = ref('');

// --- FORMS ---
const addForm = useForm({
    name: '',
    serial_number: '',
    category_id: '',
    brand_id: '',
    current_site_id: '',
    status: 'Working',
    is_attachment: 0, // 0 = Rig, 1 = Spare
    functional_group: ''
});

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
    const dataSource = activeTab.value === 'fleet' ? props.equipment.data : props.depoSpares;
    if (!dataSource) return [];
    if (!searchQuery.value) return dataSource;

    return dataSource.filter(item =>
        item.name?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        item.serial_number?.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

// --- METHODS ---
const submitAdd = () => {
    addForm.post(route('inventory.store'), {
        onSuccess: () => {
            showAddModal.value = false;
            addForm.reset();
        }
    });
};

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
            preserveScroll: true
        });
    }
};

const handleTransfer = (id, event) => {
    const siteId = event.target.value;
    if (!siteId) return;
    router.put(`/inventory/transfer/${id}`, { to_site_id: siteId });
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

                <div class="flex gap-3 w-full md:w-auto">
                    <input v-model="searchQuery" placeholder="Search S/N or Name..." class="rounded-xl border-gray-200 text-sm px-4 flex-1 md:w-64 focus:ring-2 focus:ring-indigo-500" />

                    <button @click="showAddModal = true" class="bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-2 rounded-xl font-black text-[10px] uppercase shadow-lg shadow-emerald-100 transition-all transform active:scale-95">
                        + Add Equipment
                    </button>
                </div>
            </div>

            <div class="bg-white rounded-3xl shadow-sm border border-gray-200 overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-gray-50 border-b">
                        <tr class="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            <th class="px-6 py-5">Equipment Details</th>
                            <th class="px-6 py-5">Current Site</th>
                            <th class="px-6 py-5">Status</th>
                            <th class="px-6 py-5 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 text-sm">
                        <tr v-for="item in filteredData" :key="item.id">
                            <td class="px-6 py-4">
                                <div class="font-bold text-gray-800">{{ item.name }}</div>
                                <div class="text-[10px] font-mono text-indigo-500 font-bold uppercase tracking-tighter">{{ item.serial_number }}</div>
                            </td>
                            <td class="px-6 py-4 text-xs font-bold text-gray-600">
                                {{ item.current_site?.location_name || 'Main Depo' }}
                            </td>
                            <td class="px-6 py-4">
                                <span :class="getStatusBadge(item.status)" class="px-3 py-1 rounded-full text-[9px] font-black border uppercase">
                                    {{ item.status }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-right space-x-2">
                                <button @click="openHistory(item)" class="text-indigo-600 font-black text-[10px] uppercase underline">History</button>
                                <button v-if="activeTab === 'warehouse' && !item.parent_id" @click="openLinkModal(item)" class="text-emerald-600 font-black text-[10px] uppercase underline">Link</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div v-if="showAddModal" class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 p-4 backdrop-blur-sm">
            <div class="bg-white rounded-[2rem] shadow-2xl w-full max-w-lg p-8 transform transition-all">
                <div class="flex justify-between items-center mb-6">
                    <h3 class="text-xl font-black uppercase italic text-gray-900">Add New Item</h3>
                    <button @click="showAddModal = false" class="text-2xl text-gray-400">&times;</button>
                </div>

                <form @submit.prevent="submitAdd" class="grid grid-cols-2 gap-4">
                    <div class="col-span-2">
                        <label class="text-[10px] font-black uppercase text-gray-400 ml-2">Item Name (e.g. Soilmec SR-40)</label>
                        <input v-model="addForm.name" type="text" class="w-full border-gray-200 rounded-2xl text-sm p-3 bg-gray-50 focus:bg-white" required />
                    </div>
                    <div>
                        <label class="text-[10px] font-black uppercase text-gray-400 ml-2">Serial Number</label>
                        <input v-model="addForm.serial_number" type="text" class="w-full border-gray-200 rounded-2xl text-sm p-3 bg-gray-50 focus:bg-white" required />
                    </div>
                    <div>
                        <label class="text-[10px] font-black uppercase text-gray-400 ml-2">Type</label>
                        <select v-model="addForm.is_attachment" class="w-full border-gray-200 rounded-2xl text-sm p-3 bg-gray-50 focus:bg-white">
                            <option :value="0">Rig (Machine)</option>
                            <option :value="1">Spare/Attachment</option>
                        </select>
                    </div>
                    <div class="col-span-1">
                        <label class="text-[10px] font-black uppercase text-gray-400 ml-2">Initial Site</label>
                        <select v-model="addForm.current_site_id" class="w-full border-gray-200 rounded-2xl text-sm p-3 bg-gray-50 focus:bg-white" required>
                            <option value="">Select Site</option>
                            <option v-for="site in sites" :key="site.id" :value="site.id">{{ site.location_name }}</option>
                        </select>
                    </div>
                    <div class="col-span-1">
                        <label class="text-[10px] font-black uppercase text-gray-400 ml-2">Status</label>
                        <select v-model="addForm.status" class="w-full border-gray-200 rounded-2xl text-sm p-3 bg-gray-50 focus:bg-white">
                            <option value="Working">Working</option>
                            <option value="In Stock">In Stock</option>
                            <option value="Under Repair">Under Repair</option>
                        </select>
                    </div>

                    <div class="col-span-2 flex gap-3 pt-6 border-t mt-4">
                        <button type="button" @click="showAddModal = false" class="flex-1 py-4 bg-gray-100 text-gray-500 rounded-2xl font-black uppercase text-[10px]">Cancel</button>
                        <button type="submit" class="flex-1 py-4 bg-emerald-600 text-white rounded-2xl font-black uppercase text-[10px] shadow-lg shadow-emerald-100" :disabled="addForm.processing">
                            {{ addForm.processing ? 'Creating...' : 'Create Item' }}
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div v-if="showLinkModal && linkingSpare" class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-[2rem] shadow-2xl w-full max-w-md p-8">
                <h3 class="text-xl font-black uppercase italic mb-6">Link to Machine</h3>
                <form @submit.prevent="submitLink" class="space-y-4">
                    <div>
                        <label class="text-[10px] font-black uppercase text-gray-400 ml-2">Target Rig</label>
                        <select v-model="linkForm.parent_id" class="w-full border-gray-200 rounded-2xl text-sm" required>
                            <option value="">Choose machine...</option>
                            <option v-for="rig in allRigs" :key="rig.id" :value="rig.id">{{ rig.name }} ({{ rig.serial_number }})</option>
                        </select>
                    </div>
                    <div class="flex gap-3 pt-4">
                        <button type="button" @click="showLinkModal = false" class="flex-1 py-4 bg-gray-100 text-gray-500 rounded-2xl font-black uppercase text-[10px]">Cancel</button>
                        <button type="submit" class="flex-1 py-4 bg-indigo-600 text-white rounded-2xl font-black uppercase text-[10px]" :disabled="linkForm.processing">Link Spare</button>
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
                    <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4 italic text-center">Linked Components</h4>
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

                <div>
                    <div class="flex justify-between items-center mb-4">
                        <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest italic">Service Logs</h4>
                        <button @click="showLogForm = !showLogForm" class="bg-indigo-600 text-white px-3 py-1 rounded-lg text-[9px] font-black uppercase">+ New Log</button>
                    </div>

                    <div v-if="showLogForm" class="bg-gray-50 p-6 rounded-3xl border border-dashed border-indigo-200 mb-6">
                        <form @submit.prevent="submitLog" class="grid grid-cols-2 gap-4">
                            <input v-model="logForm.service_date" type="date" class="w-full border-gray-200 rounded-xl text-xs" required />
                            <select v-model="logForm.mechanic_id" class="w-full border-gray-200 rounded-xl text-xs" required>
                                <option value="">Select Mechanic</option>
                                <option v-for="emp in employees" :key="emp.id" :value="emp.id">{{ emp.name }}</option>
                            </select>
                            <input v-model="logForm.running_hours" type="number" placeholder="Running Hours" class="w-full border-gray-200 rounded-xl text-xs" required />
                            <input v-model="logForm.service_type" placeholder="Type of Service" class="w-full border-gray-200 rounded-xl text-xs" required />
                            <textarea v-model="logForm.parts_replaced" placeholder="Notes..." class="col-span-2 w-full border-gray-200 rounded-xl text-xs" rows="2"></textarea>
                            <button type="submit" class="col-span-2 py-3 bg-indigo-600 text-white rounded-xl font-black uppercase text-[10px]" :disabled="logForm.processing">Save Log</button>
                        </form>
                    </div>

                    <div v-if="(selectedItem.maintenance_logs || selectedItem.maintenanceLogs)?.length > 0" class="space-y-4">
                        <div v-for="log in (selectedItem.maintenance_logs || selectedItem.maintenanceLogs)" :key="log.id" class="p-5 border rounded-3xl bg-gray-50">
                            <div class="flex justify-between font-black text-[10px] mb-2 text-gray-400 uppercase tracking-widest">
                                <span>{{ log.service_date }}</span>
                                <span class="text-emerald-500">{{ log.running_hours }} HRS</span>
                            </div>
                            <p class="font-black text-gray-800 text-sm uppercase mb-1">{{ log.service_type }}</p>
                            <p class="text-xs text-gray-500">{{ log.parts_replaced }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
