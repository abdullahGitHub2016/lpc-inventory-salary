<script setup>
import { useForm, Head, Link, router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    equipment: Array,
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
    serial_number: '',
    current_site_id: '',
    status: 'Working'
});

const editForm = useForm({
    name: '',
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
    editForm.name = item.name;
    editForm.serial_number = item.serial_number;
    editForm.status = item.status;
};

const submitUpdate = () => {
    editForm.put(`/inventory/${editingItem.value.id}`, {
        onSuccess: () => editingItem.value = null,
    });
};

const deleteItem = (id) => {
    if (confirm('Permanently delete this machine?')) {
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

    <div class="min-h-screen bg-gray-50 p-6">
        <div class="max-w-6xl mx-auto">

            <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 mb-6">
                <div class="flex flex-col md:flex-row justify-between items-center gap-4">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Fleet Inventory</h1>
                        <p class="text-sm text-gray-500">Total Units: {{ equipment.length }}</p>
                    </div>

                    <div class="flex flex-wrap gap-3 w-full md:w-auto">
                        <input v-model="searchQuery" type="text" placeholder="Search by name or serial..." class="rounded-lg border-gray-300 shadow-sm focus:ring-indigo-500 w-full md:w-64" />

                        <button @click="showAddModal = true" class="bg-green-600 text-white px-5 py-2 rounded-lg font-bold hover:bg-green-700 transition shadow-sm">
                            + Add Machine
                        </button>

                        <Link href="/inventory/transfer" class="bg-indigo-600 text-white px-5 py-2 rounded-lg font-bold hover:bg-indigo-700 transition shadow-sm">
                            Transfer Rig
                        </Link>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-gray-50 border-b border-gray-100">
                        <tr>
                            <th class="px-6 py-4 text-[10px] font-bold text-gray-400 uppercase">Machine Details</th>
                            <th class="px-6 py-4 text-[10px] font-bold text-gray-400 uppercase">Current Site</th>
                            <th class="px-6 py-4 text-[10px] font-bold text-gray-400 uppercase">Status</th>
                            <th class="px-6 py-4 text-right text-[10px] font-bold text-gray-400 uppercase">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr v-for="item in filteredEquipment" :key="item.id" class="hover:bg-gray-50 transition">
                            <td class="px-6 py-4">
                                <div class="font-bold text-gray-800">{{ item.name }}</div>
                                <div class="text-xs font-mono text-indigo-500">{{ item.serial_number }}</div>
                            </td>
                            <td class="px-6 py-4">
                                <span class="text-sm font-medium text-gray-600">{{ item.current_site?.location_name || 'Store' }}</span>
                            </td>
                            <td class="px-6 py-4">
                                <span :class="getStatusBadge(item.status)" class="px-3 py-1 rounded-full text-[10px] font-bold border">
                                    {{ item.status }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-right space-x-4">
                                <button @click="openEditModal(item)" class="text-indigo-600 font-bold text-xs">EDIT</button>
                                <button @click="deleteItem(item.id)" class="text-red-400 font-bold text-xs">DELETE</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div v-if="showAddModal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md">
                <div class="p-6 border-b flex justify-between items-center">
                    <h3 class="text-lg font-bold">Register New Machine</h3>
                    <button @click="showAddModal = false" class="text-gray-400 hover:text-gray-600">&times;</button>
                </div>
                <form @submit.prevent="submitAdd" class="p-6 space-y-4">
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Name</label>
                        <input v-model="addForm.name" type="text" class="w-full mt-1 border-gray-300 rounded-lg" required />
                    </div>
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Serial Number</label>
                        <input v-model="addForm.serial_number" type="text" class="w-full mt-1 border-gray-300 rounded-lg" required />
                    </div>
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Assign to Site</label>
                        <select v-model="addForm.current_site_id" class="w-full mt-1 border-gray-300 rounded-lg" required>
                            <option value="">-- Choose --</option>
                            <option v-for="site in sites" :key="site.id" :value="site.id">{{ site.location_name }}</option>
                        </select>
                    </div>
                    <div class="flex gap-3 pt-4">
                        <button type="button" @click="showAddModal = false" class="flex-1 py-3 bg-gray-100 rounded-xl font-bold">Cancel</button>
                        <button type="submit" class="flex-1 py-3 bg-green-600 text-white rounded-xl font-bold hover:bg-green-700">Add Unit</button>
                    </div>
                </form>
            </div>
        </div>

        <div v-if="editingItem" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md">
                <div class="p-6 border-b">
                    <h3 class="text-lg font-bold">Edit {{ editingItem.serial_number }}</h3>
                </div>
                <form @submit.prevent="submitUpdate" class="p-6 space-y-4">
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Machine Name</label>
                        <input v-model="editForm.name" type="text" class="w-full mt-1 border-gray-300 rounded-lg" />
                    </div>
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Serial Number</label>
                        <input v-model="editForm.serial_number" type="text" class="w-full mt-1 border-gray-300 rounded-lg" />
                    </div>
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Status</label>
                        <select v-model="editForm.status" class="w-full mt-1 border-gray-300 rounded-lg">
                            <option value="Working">Working</option>
                            <option value="Under Repair">Under Repair</option>
                            <option value="Maintenance">Maintenance</option>
                        </select>
                    </div>
                    <div class="flex gap-3 pt-4">
                        <button type="button" @click="editingItem = null" class="flex-1 py-3 bg-gray-100 rounded-xl font-bold">Cancel</button>
                        <button type="submit" class="flex-1 py-3 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700">Update</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>
