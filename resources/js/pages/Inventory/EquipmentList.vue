<script setup>
import { useForm, Head, Link, router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    equipment: Array,
    categories: Array,
    brands: Array,
    sites: Array
});

// --- STATE CONTROL ---
const showAddModal = ref(false);
const editingItem = ref(null);
const searchQuery = ref('');

// --- SEARCH FILTER ---
const filteredEquipment = computed(() => {
    return props.equipment.filter(item =>
        item.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        item.serial_number.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

// --- FORMS ---
const addForm = useForm({
    name: '',
    category_id: '',
    brand_id: '',
    serial_number: '',
    current_site_id: '',
    status: 'Working'
});

const editForm = useForm({
    name: '',
    category_id: '',
    brand_id: '',
    serial_number: '',
    status: ''
});

// --- ACTIONS ---
const submitAdd = () => {
    addForm.post('/inventory', {
        onSuccess: () => {
            addForm.reset();
            showAddModal.value = false;
        },
    });
};

const openEditModal = (item) => {
    editingItem.value = item;

    // Fill the form with existing data
    editForm.name = item.name;
    editForm.serial_number = item.serial_number;
    editForm.category_id = item.category_id;
    editForm.brand_id = item.brand_id;

    // This MUST match the string in your <option value="..."> exactly
    editForm.status = item.status;
};

const submitUpdate = () => {
    editForm.put(`/inventory/${editingItem.value.id}`, {
        onSuccess: () => editingItem.value = null,
    });
};

const deleteItem = (id) => {
    if (confirm('Permanently delete this item?')) {
        router.delete(`/inventory/${id}`);
    }
};

const getStatusBadge = (status) => {
    const map = {
        'Working': 'bg-green-100 text-green-700 border-green-200',
        'Under Repair': 'bg-red-100 text-red-700 border-red-200',
        'Maintenance': 'bg-yellow-100 text-yellow-700 border-yellow-200',
    };
    return map[status] || 'bg-gray-100 text-gray-700 border-gray-200';
};
</script>

<template>
    <Head title="Equipment Inventory" />

    <div class="min-h-screen bg-gray-50 p-4 md:p-8">
        <div class="max-w-7xl mx-auto">

            <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 mb-6">
                <div class="flex flex-col md:flex-row justify-between items-center gap-4">
                    <div>
                        <h1 class="text-2xl font-black text-gray-900 uppercase">Fleet Inventory</h1>
                        <p class="text-sm text-gray-500 font-medium">Manage Rigs, Tools, and Testing Instruments</p>
                    </div>

                    <div class="flex flex-wrap gap-3 w-full md:w-auto">
                        <input v-model="searchQuery" type="text" placeholder="Search machine..." class="rounded-xl border-gray-300 shadow-sm focus:ring-indigo-500 w-full md:w-64" />

                        <button @click="showAddModal = true" class="bg-emerald-600 text-white px-6 py-2.5 rounded-xl font-bold hover:bg-emerald-700 transition shadow-lg shadow-emerald-100">
                            + Add New
                        </button>

                        <Link href="/inventory/transfer" class="bg-indigo-600 text-white px-6 py-2.5 rounded-xl font-bold hover:bg-indigo-700 transition shadow-lg shadow-indigo-100 text-center">
                            Transfer Rig
                        </Link>
                    </div>
                </div>
            </div>

            <div class="hidden md:block bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-gray-50 border-b border-gray-100">
                        <tr>
                            <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">Machine / SN</th>
                            <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">Type & Brand</th>
                            <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">Current Site</th>
                            <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">Status</th>
                            <th class="px-6 py-4 text-right text-[10px] font-black text-gray-400 uppercase tracking-widest">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr v-for="item in filteredEquipment" :key="item.id" class="hover:bg-indigo-50/30 transition cursor-default">
                            <td class="px-6 py-4">
                                <div class="font-bold text-gray-800">{{ item.name }}</div>
                                <div class="text-xs font-mono text-indigo-500 uppercase">{{ item.serial_number }}</div>
                            </td>
                            <td class="px-6 py-4">
                                <div class="text-sm font-semibold text-gray-700">{{ item.brand?.name || 'Generic' }}</div>
                                <div class="text-[10px] font-bold text-gray-400 uppercase">{{ item.category?.name || 'Uncategorized' }}</div>
                            </td>
                            <td class="px-6 py-4">
                                <span class="text-sm font-medium text-gray-600 italic">{{ item.current_site?.location_name || 'Main Store' }}</span>
                            </td>
                            <td class="px-6 py-4">
                                <span :class="getStatusBadge(item.status)" class="px-3 py-1 rounded-full text-[10px] font-black border uppercase">
                                    {{ item.status }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-right space-x-3">
                                <button @click="openEditModal(item)" class="text-indigo-600 font-black text-[10px] hover:underline">EDIT</button>
                                <button @click="deleteItem(item.id)" class="text-red-400 font-black text-[10px] hover:underline">DELETE</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="md:hidden space-y-4">
                <div v-for="item in filteredEquipment" :key="'mob-' + item.id" class="bg-white p-5 rounded-2xl border border-gray-200 shadow-sm">
                    <div class="flex justify-between items-start mb-3">
                        <div>
                            <h3 class="font-bold text-gray-900">{{ item.name }}</h3>
                            <p class="text-xs font-mono text-indigo-500">{{ item.serial_number }}</p>
                        </div>
                        <span :class="getStatusBadge(item.status)" class="px-2 py-1 rounded-lg text-[9px] font-black border uppercase">
                            {{ item.status }}
                        </span>
                    </div>
                    <div class="grid grid-cols-2 gap-2 text-[10px] mb-4">
                        <div class="bg-gray-50 p-2 rounded-lg">
                            <span class="text-gray-400 block uppercase">Brand</span>
                            <span class="font-bold text-gray-700">{{ item.brand?.name || '-' }}</span>
                        </div>
                        <div class="bg-gray-50 p-2 rounded-lg">
                            <span class="text-gray-400 block uppercase">Category</span>
                            <span class="font-bold text-gray-700">{{ item.category?.name || '-' }}</span>
                        </div>
                    </div>
                    <div class="flex gap-2">
                        <button @click="openEditModal(item)" class="flex-1 py-2.5 bg-indigo-600 text-white rounded-xl text-[10px] font-black uppercase">Edit</button>
                        <button @click="deleteItem(item.id)" class="flex-1 py-2.5 bg-gray-100 text-gray-600 rounded-xl text-[10px] font-black uppercase">Delete</button>
                    </div>
                </div>
            </div>
        </div>

        <div v-if="showAddModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden border border-white/20">
                <div class="p-6 border-b flex justify-between items-center bg-gray-50/50">
                    <h3 class="text-xl font-black text-gray-800 uppercase tracking-tight">New Asset Registration</h3>
                    <button @click="showAddModal = false" class="text-gray-400 hover:text-gray-950 transition text-2xl">&times;</button>
                </div>
                <form @submit.prevent="submitAdd" class="p-8 space-y-5">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <div>
                            <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Machine Name</label>
                            <input v-model="addForm.name" type="text" class="w-full mt-1.5 border-gray-200 rounded-xl focus:ring-indigo-500 focus:border-indigo-500" required />
                        </div>
                        <div>
                            <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Serial Number</label>
                            <input v-model="addForm.serial_number" type="text" class="w-full mt-1.5 border-gray-200 rounded-xl focus:ring-indigo-500" required />
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <div>
                            <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Equipment Category</label>
                            <select v-model="addForm.category_id" class="w-full mt-1.5 border-gray-200 rounded-xl focus:ring-indigo-500" required>
                                <option value="" disabled>-- Select Type --</option>
                                <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Brand / Maker</label>
                            <select v-model="addForm.brand_id" class="w-full mt-1.5 border-gray-200 rounded-xl focus:ring-indigo-500" required>
                                <option value="" disabled>-- Select Brand --</option>
                                <option v-for="b in brands" :key="b.id" :value="b.id">{{ b.name }}</option>
                            </select>
                        </div>
                    </div>

                    <div>
                        <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Initial Site Deployment</label>
                        <select v-model="addForm.current_site_id" class="w-full mt-1.5 border-gray-300 rounded-xl" required>
                            <option value="">-- Choose Storage/Site --</option>
                            <option v-for="site in sites" :key="site.id" :value="site.id">{{ site.location_name }}</option>
                        </select>
                    </div>

                    <div class="flex gap-4 pt-4 border-t border-gray-100">
                        <button type="button" @click="showAddModal = false" class="flex-1 py-3.5 bg-gray-100 text-gray-600 rounded-2xl font-black uppercase text-xs">Cancel</button>
                        <button type="submit" class="flex-1 py-3.5 bg-emerald-600 text-white rounded-2xl font-black uppercase text-xs shadow-lg shadow-emerald-100">Register Asset</button>
                    </div>
                </form>
            </div>
        </div>

        <div v-if="editingItem" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden">
                <div class="p-6 border-b bg-gray-50/50">
                    <h3 class="text-lg font-black text-gray-800 uppercase">Update Equipment Info</h3>
                </div>
                <form @submit.prevent="submitUpdate" class="p-8 space-y-4">
                    <div>
                        <label class="text-[10px] font-black text-gray-400 uppercase">Machine Name</label>
                        <input v-model="editForm.name" type="text" class="w-full mt-1.5 border-gray-200 rounded-xl" />
                    </div>
                    <div>
                        <label class="text-[10px] font-black text-gray-400 uppercase">Serial Number</label>
                        <input v-model="editForm.serial_number" type="text" class="w-full mt-1.5 border-gray-200 rounded-xl" />
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="text-[10px] font-black text-gray-400 uppercase">Category</label>
                            <select v-model="editForm.category_id" class="w-full mt-1.5 border-gray-200 rounded-xl">
                                <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-[10px] font-black text-gray-400 uppercase">Brand</label>
                            <select v-model="editForm.brand_id" class="w-full mt-1.5 border-gray-200 rounded-xl">
                                <option v-for="b in brands" :key="b.id" :value="b.id">{{ b.name }}</option>
                            </select>
                        </div>
                    </div>
                    <div>
    <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Operational Status</label>
    <select v-model="editForm.status" class="w-full mt-1.5 border-gray-200 rounded-xl focus:ring-indigo-500">
        <option value="" disabled>-- Select Status --</option>
        <option value="Working">Working</option>
        <option value="Under Repair">Under Repair</option>
        <option value="Maintenance">Maintenance</option>
    </select>
</div>
                    <div class="flex gap-3 pt-6">
                        <button type="button" @click="editingItem = null" class="flex-1 py-3.5 bg-gray-100 text-gray-500 rounded-2xl font-black uppercase text-xs">Close</button>
                        <button type="submit" class="flex-1 py-3.5 bg-indigo-600 text-white rounded-2xl font-black uppercase text-xs shadow-lg shadow-indigo-100">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>
