<script setup>
import { useForm, Head, Link, router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    equipment: Array,
    sites: Array
});

// --- STATE CONTROL ---
const editingItem = ref(null); // When this is not null, the modal shows
const searchQuery = ref('');

// --- SEARCH FILTER ---
const filteredEquipment = computed(() => {
    return props.equipment.filter(item =>
        item.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        item.serial_number.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

// --- ADD FORM ---
const addForm = useForm({
    name: '',
    serial_number: '',
    current_site_id: '',
    status: 'Working'
});

// --- EDIT FORM ---
const editForm = useForm({
    name: '',
    serial_number: '',
    status: ''
});

// --- FUNCTIONS ---
const submitAdd = () => {
    addForm.post('/inventory', {
        onSuccess: () => {
            addForm.reset();
            alert('New equipment added!');
        },
    });
};

const openEditModal = (item) => {
    editingItem.value = item;
    // This part ensures the data shows up in the edit fields
    editForm.name = item.name;
    editForm.serial_number = item.serial_number;
    editForm.status = item.status;
};

const submitUpdate = () => {
    editForm.put(`/inventory/${editingItem.value.id}`, {
        onSuccess: () => {
            editingItem.value = null;
            alert('Equipment updated successfully');
        },
    });
};

const deleteItem = (id) => {
    if (confirm('Are you sure? This will permanently delete the machine.')) {
        router.delete(`/inventory/${id}`);
    }
};

const getStatusBadge = (status) => {
    const map = {
        'Working': 'bg-green-100 text-green-700 border-green-200',
        'Under Repair': 'bg-red-100 text-red-700 border-red-200',
        'Maintenance': 'bg-yellow-100 text-yellow-700 border-yellow-200',
        'Standby': 'bg-gray-100 text-gray-700 border-gray-200'
    };
    return map[status] || 'bg-blue-100 text-blue-700 border-blue-200';
};
</script>

<template>
    <Head title="Equipment Management" />

    <div class="min-h-screen bg-gray-50 p-6">
        <div class="max-w-7xl mx-auto">

            <div class="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 uppercase tracking-tight">Fleet Inventory</h1>
                    <p class="text-sm text-gray-500">Manage your piling rigs and site machinery</p>
                </div>
                <div class="flex gap-4 w-full md:w-auto">
                    <input v-model="searchQuery" type="text" placeholder="Search machine..." class="rounded-lg border-gray-300 shadow-sm focus:ring-indigo-500 focus:border-indigo-500 w-full" />
                    <Link href="/inventory/transfer" class="bg-indigo-600 text-white px-6 py-2 rounded-lg font-bold hover:bg-indigo-700 shadow-lg whitespace-nowrap">
                        Transfer Rig
                    </Link>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">

                <div class="lg:col-span-1">
                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                        <h2 class="font-bold text-gray-800 mb-4 uppercase text-xs tracking-widest">Add New Unit</h2>
                        <form @submit.prevent="submitAdd" class="space-y-4">
                            <div>
                                <label class="text-[10px] font-bold text-gray-400 uppercase">Equipment Name</label>
                                <input v-model="addForm.name" type="text" class="w-full mt-1 border-gray-300 rounded-lg text-sm" placeholder="e.g. SANY Rig 200" required />
                            </div>
                            <div>
                                <label class="text-[10px] font-bold text-gray-400 uppercase">Serial Number</label>
                                <input v-model="addForm.serial_number" type="text" class="w-full mt-1 border-gray-300 rounded-lg text-sm" placeholder="SN-XXXX" required />
                            </div>
                            <div>
                                <label class="text-[10px] font-bold text-gray-400 uppercase">Initial Site</label>
                                <select v-model="addForm.current_site_id" class="w-full mt-1 border-gray-300 rounded-lg text-sm" required>
                                    <option value="">-- Select Store --</option>
                                    <option v-for="site in sites" :key="site.id" :value="site.id">{{ site.location_name }}</option>
                                </select>
                            </div>
                            <button type="submit" class="w-full bg-green-600 text-white py-3 rounded-lg font-bold hover:bg-green-700 transition">Save Unit</button>
                        </form>
                    </div>
                </div>

                <div class="lg:col-span-3">
                    <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
                        <table class="w-full text-left">
                            <thead class="bg-gray-50 border-b border-gray-100">
                                <tr>
                                    <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase">Machine Details</th>
                                    <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase">Location</th>
                                    <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase">Status</th>
                                    <th class="px-6 py-4 text-right text-[10px] font-black text-gray-400 uppercase">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <tr v-for="item in filteredEquipment" :key="item.id" class="hover:bg-indigo-50/20 transition">
                                    <td class="px-6 py-4">
                                        <div class="font-bold text-gray-800">{{ item.name }}</div>
                                        <div class="text-xs font-mono text-indigo-500">{{ item.serial_number }}</div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="text-sm font-medium text-gray-600">{{ item.current_site?.location_name || 'N/A' }}</span>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span :class="getStatusBadge(item.status)" class="px-3 py-1 rounded-full text-[10px] font-bold border">
                                            {{ item.status }}
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-right space-x-4">
                                        <button @click="openEditModal(item)" class="text-blue-600 font-bold text-xs hover:underline">EDIT</button>
                                        <button @click="deleteItem(item.id)" class="text-red-400 font-bold text-xs hover:underline">REMOVE</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div v-if="editingItem" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden">
                <div class="p-6 border-b border-gray-100">
                    <h3 class="text-lg font-bold text-gray-800">Edit Equipment Settings</h3>
                    <p class="text-xs text-gray-500">Updating: {{ editingItem.serial_number }}</p>
                </div>
                <form @submit.prevent="submitUpdate" class="p-6 space-y-4">
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Machine Name</label>
                        <input v-model="editForm.name" type="text" class="w-full mt-1 border-gray-300 rounded-lg text-sm" />
                    </div>
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Serial Number</label>
                        <input v-model="editForm.serial_number" type="text" class="w-full mt-1 border-gray-300 rounded-lg text-sm" />
                    </div>
                    <div>
                        <label class="text-[10px] font-bold text-gray-400 uppercase">Mechanical Status</label>
                        <select v-model="editForm.status" class="w-full mt-1 border-gray-300 rounded-lg text-sm">
                            <option value="Working">Working</option>
                            <option value="Under Repair">Under Repair</option>
                            <option value="Maintenance">Maintenance</option>
                            <option value="Standby">Standby</option>
                        </select>
                    </div>
                    <div class="flex gap-3 pt-4">
                        <button type="button" @click="editingItem = null" class="flex-1 py-3 bg-gray-100 text-gray-600 rounded-xl font-bold hover:bg-gray-200 transition">Cancel</button>
                        <button type="submit" class="flex-1 py-3 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-lg transition">Update Unit</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>
