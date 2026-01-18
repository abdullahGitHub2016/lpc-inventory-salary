<script setup>
import { useForm, Head, Link, router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    equipment: Object,    // Main Rigs (is_attachment: 0) - Paginated
    depoSpares: Array,    // Warehouse Items (is_attachment: 1) - Array
    categories: Array,
    brands: Array,
    sites: Array
});

// --- STATE ---
const activeTab = ref('fleet');
const showAddModal = ref(false);
const editingItem = ref(null);
const showLogsModal = ref(false);
const selectedItem = ref(null);
const searchQuery = ref('');

// --- ADD FORM ---
const addForm = useForm({
    name: '',
    serial_number: '',
    category_id: '',
    brand_id: '',
    current_site_id: '',
    status: 'Working',
    is_attachment: 0 // Controller uses this to decide where it lands
});

const editForm = useForm({
    name: '',
    serial_number: '',
    status: ''
});

// --- DATA FILTERING ---
const filteredData = computed(() => {
    // IMPORTANT: 'equipment' has a '.data' property because it is paginated
    const dataSource = activeTab.value === 'fleet' ? props.equipment.data : props.depoSpares;
    if (!dataSource) return [];
    if (!searchQuery.value) return dataSource;

    return dataSource.filter(item =>
        item.name?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        item.serial_number?.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

// --- METHODS ---
const openEdit = (item) => {
    editingItem.value = item;
    editForm.name = item.name;
    editForm.serial_number = item.serial_number;
    editForm.status = item.status;
};

const submitAdd = () => {
    addForm.post('/inventory', {
        onSuccess: () => {
            addForm.reset();
            showAddModal.value = false;
        },
        onError: (err) => console.log(err)
    });
};

const submitUpdate = () => {
    editForm.put(`/inventory/${editingItem.value.id}`, {
        onSuccess: () => { editingItem.value = null; }
    });
};

const handleTransfer = (id, event) => {
    const siteId = event.target.value;
    if (!siteId) return;
    router.post('/inventory/transfer', {
        equipment_id: id,
        to_site_id: siteId,
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

    <div class="min-h-screen bg-gray-50 p-4 md:p-8">
        <div class="max-w-7xl mx-auto">

            <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-200 mb-6 flex flex-col md:flex-row justify-between items-center gap-4">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 uppercase italic">Fleet Inventory</h1>
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
                        <tr v-for="item in filteredData" :key="item.id">
                            <td class="px-6 py-4">
                                <div class="font-bold text-gray-800">{{ item.name }}</div>
                                <div class="text-[10px] font-mono text-indigo-500 font-bold uppercase">{{ item.serial_number }}</div>
                            </td>
                            <td class="px-6 py-4">
                                <span class="text-gray-600 font-bold text-xs block mb-1">{{ item.current_site?.location_name || 'Main Depo' }}</span>
                                <select @change="handleTransfer(item.id, $event)" class="text-[9px] border-none bg-gray-100 rounded-lg p-1 w-28 cursor-pointer">
                                    <option value="">Move To...</option>
                                    <option v-for="site in sites" :key="site.id" :value="site.id">{{ site.location_name }}</option>
                                </select>
                            </td>
                            <td class="px-6 py-4">
                                <span :class="getStatusBadge(item.status)" class="px-3 py-1 rounded-full text-[9px] font-black border uppercase">
                                    {{ item.status }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-right space-x-2">
                                <button @click="selectedItem = item; showLogsModal = true" class="text-indigo-600 font-black text-[10px] uppercase underline">History</button>
                                <button @click="openEdit(item)" class="text-amber-600 font-black text-[10px] uppercase underline">Edit</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div v-if="activeTab === 'fleet' && equipment.links.length > 3" class="flex justify-center gap-1 py-8">
                <Link v-for="(link, k) in equipment.links" :key="k" :href="link.url || '#'" v-html="link.label"
                      class="px-4 py-2 rounded-xl text-xs font-bold border"
                      :class="[link.active ? 'bg-indigo-600 text-white' : 'bg-white text-gray-600', !link.url ? 'opacity-30' : '']" />
            </div>
        </div>

        <div v-if="showAddModal" class="fixed inset-0 bg-slate-900/60 flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden">
                <div class="p-6 border-b bg-gray-50 flex justify-between items-center">
                    <h3 class="text-lg font-black text-gray-800 uppercase italic">Add New Item</h3>
                    <button @click="showAddModal = false" class="text-2xl font-light">&times;</button>
                </div>
                <form @submit.prevent="submitAdd" class="p-8 space-y-4">
                    <div class="flex border rounded-xl overflow-hidden mb-2">
                        <button type="button" @click="addForm.is_attachment = 0" class="flex-1 py-2 text-[10px] font-black uppercase" :class="addForm.is_attachment === 0 ? 'bg-indigo-600 text-white' : 'bg-gray-50'">Fleet Rig</button>
                        <button type="button" @click="addForm.is_attachment = 1" class="flex-1 py-2 text-[10px] font-black uppercase" :class="addForm.is_attachment === 1 ? 'bg-indigo-600 text-white' : 'bg-gray-50'">Depo Spare</button>
                    </div>

                    <input v-model="addForm.name" placeholder="Name" class="w-full border-gray-200 rounded-xl" required />
                    <input v-model="addForm.serial_number" placeholder="Serial Number" class="w-full border-gray-200 rounded-xl" required />

                    <div class="grid grid-cols-2 gap-2">
                        <select v-model="addForm.category_id" class="border-gray-200 rounded-xl text-xs" required>
                            <option value="">Category</option>
                            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                        </select>
                        <select v-model="addForm.brand_id" class="border-gray-200 rounded-xl text-xs" required>
                            <option value="">Brand</option>
                            <option v-for="brand in brands" :key="brand.id" :value="brand.id">{{ brand.name }}</option>
                        </select>
                    </div>

                    <select v-model="addForm.current_site_id" class="w-full border-gray-200 rounded-xl text-xs" required>
                        <option value="">Initial Site Location</option>
                        <option v-for="site in sites" :key="site.id" :value="site.id">{{ site.location_name }}</option>
                    </select>

                    <button type="submit" class="w-full py-4 bg-emerald-600 text-white rounded-2xl uppercase font-black text-xs shadow-lg">Save Item</button>
                </form>
            </div>
        </div>

        <div v-if="editingItem" class="fixed inset-0 bg-slate-900/60 flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md p-8">
                <h3 class="text-lg font-black uppercase mb-6 italic">Edit Machine</h3>
                <form @submit.prevent="submitUpdate" class="space-y-4">
                    <input v-model="editForm.name" class="w-full border-gray-200 rounded-xl" />
                    <input v-model="editForm.serial_number" class="w-full border-gray-200 rounded-xl" />
                    <select v-model="editForm.status" class="w-full border-gray-200 rounded-xl">
                        <option value="Working">Working</option>
                        <option value="Maintenance">Maintenance</option>
                        <option value="In Stock">In Stock</option>
                    </select>
                    <button type="submit" class="w-full py-4 bg-indigo-600 text-white rounded-2xl uppercase font-black text-xs shadow-lg">Update</button>
                </form>
            </div>
        </div>

        <div v-if="showLogsModal && selectedItem" class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-[2rem] shadow-2xl w-full max-w-2xl max-h-[80vh] overflow-y-auto p-8">
                <div class="flex justify-between items-center mb-8 border-b pb-4">
                    <div>
                        <h3 class="text-xl font-black uppercase italic text-gray-900">{{ selectedItem.name }}</h3>
                        <p class="text-[10px] font-mono text-indigo-500 font-bold">S/N: {{ selectedItem.serial_number }}</p>
                    </div>
                    <button @click="showLogsModal = false" class="text-3xl font-light">&times;</button>
                </div>
                <div>
                    <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4">Service Records</h4>
                    <div v-if="selectedItem.maintenanceLogs?.length > 0" class="space-y-4">
                        <div v-for="log in selectedItem.maintenanceLogs" :key="log.id" class="p-5 border rounded-3xl bg-gray-50">
                            <div class="flex justify-between font-black text-[10px] mb-2 text-gray-400 uppercase">
                                <span>{{ log.service_date }}</span>
                                <span class="text-emerald-500">{{ log.running_hours }} HRS</span>
                            </div>
                            <p class="font-black text-gray-800 text-sm uppercase mb-1">{{ log.service_type }}</p>
                            <p class="text-xs text-gray-500 leading-relaxed">{{ log.parts_replaced }}</p>
                        </div>
                    </div>
                    <p v-else class="text-xs italic text-gray-400 text-center py-4 bg-gray-50 rounded-xl">No records found.</p>
                </div>
            </div>
        </div>
    </div>
</template>
