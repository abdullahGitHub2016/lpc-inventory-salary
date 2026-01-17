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
    brand: '',
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

    // Fill the form fields
    editForm.name = item.name;
    editForm.serial_number = item.serial_number;

    // FORCING THE MATCH:
    // This ensures that even if the DB is 'working', it matches the 'Working' option
    const statusMap = {
        'working': 'Working',
        'under repair': 'Under Repair',
        'maintenance': 'Maintenance',
        'standby': 'Standby'
    };

    // If the item.status is lowercase, map it. Otherwise, use the original.
    editForm.status = statusMap[item.status.toLowerCase()] || item.status;
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

            <div class="mt-8">

    <div class="hidden md:block bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
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
                        <div class="text-[10px] text-gray-400">{{ item.brand }}</div>
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

    <div class="md:hidden space-y-4">
        <div v-for="item in filteredEquipment" :key="'mob-' + item.id" class="bg-white p-5 rounded-2xl shadow-sm border border-gray-200">
            <div class="flex justify-between items-start mb-3">
                <div>
                    <h3 class="font-bold text-gray-900 leading-tight">{{ item.name }}</h3>
                    <p class="text-xs font-mono text-indigo-500 uppercase">{{ item.serial_number }}</p>
                    <p class="text-[10px] text-gray-400 mt-1">Brand: {{ item.brand || 'N/A' }}</p>
                </div>
                <span :class="getStatusBadge(item.status)" class="px-3 py-1 rounded-full text-[10px] font-bold border">
                    {{ item.status }}
                </span>
            </div>

            <div class="flex items-center gap-2 mb-4 p-2 bg-gray-50 rounded-lg">
                <span class="text-[10px] font-bold text-gray-400 uppercase">Location:</span>
                <span class="text-xs font-medium text-gray-700">{{ item.current_site?.location_name || 'Main Store' }}</span>
            </div>

            <div class="flex gap-2">
                <button @click="openEditModal(item)" class="flex-1 py-2 bg-indigo-50 text-indigo-600 rounded-lg text-xs font-bold uppercase tracking-wider">
                    Edit
                </button>
                <button @click="deleteItem(item.id)" class="flex-1 py-2 bg-red-50 text-red-600 rounded-lg text-xs font-bold uppercase tracking-wider">
                    Delete
                </button>
            </div>
        </div>
    </div>

    <div v-if="filteredEquipment.length === 0" class="bg-white rounded-2xl p-12 text-center border-2 border-dashed border-gray-200 mt-4">
        <p class="text-gray-400 italic">No equipment found matching your search.</p>
    </div>
</div>
        </div>

<div v-if="showAddModal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden">
        <div class="p-6 border-b flex justify-between items-center bg-gray-50">
            <h3 class="text-lg font-bold">Register New Machine</h3>
            <button @click="showAddModal = false" class="text-gray-400 hover:text-gray-600 text-2xl">&times;</button>
        </div>

        <form @submit.prevent="submitAdd" class="p-6 space-y-4">
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="text-[10px] font-bold text-gray-400 uppercase">Machine Name / Model</label>
                    <input v-model="addForm.name" type="text"
                           placeholder="e.g. SANY SR285R"
                           class="w-full mt-1 border-gray-300 rounded-lg text-sm" required />
                </div>
                <div>
                    <label class="text-[10px] font-bold text-gray-400 uppercase">Serial Number (VIN)</label>
                    <input v-model="addForm.serial_number" type="text"
                           placeholder="SN-9920-X"
                           class="w-full mt-1 border-gray-300 rounded-lg text-sm" required />
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="text-[10px] font-bold text-gray-400 uppercase">Brand</label>
                    <select v-model="addForm.brand" class="w-full mt-1 border-gray-300 rounded-lg text-sm">
                        <option value="" selected>-- Select Brand --</option>
                        <option value="SANY">SANY</option>
                        <option value="Bauer">Bauer</option>
                        <option value="Casagrande">Casagrande</option>
                        <option value="XCMG">XCMG</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <div>
                    <label class="text-[10px] font-bold text-gray-400 uppercase">Initial Site Assignment</label>
                    <select v-model="addForm.current_site_id" class="w-full mt-1 border-gray-300 rounded-lg text-sm" required>
                        <option value="">-- Select Store --</option>
                        <option v-for="site in sites" :key="site.id" :value="site.id">{{ site.location_name }}</option>
                    </select>
                </div>
            </div>

            <div>
                <label class="text-[10px] font-bold text-gray-400 uppercase">Hourly Rental Rate (Optional)</label>
                <div class="relative">
                    <span class="absolute left-3 top-2 text-gray-400">৳</span>
                    <input v-model="addForm.hourly_rate" type="number"
                           placeholder="5000"
                           class="w-full mt-1 pl-7 border-gray-300 rounded-lg text-sm" />
                </div>
                <p class="text-[10px] text-gray-400 mt-1">Used for calculating project expenses.</p>
            </div>

            <div class="flex gap-3 pt-4 border-t">
                <button type="button" @click="showAddModal = false" class="flex-1 py-3 bg-gray-100 rounded-xl font-bold text-gray-600">Cancel</button>
                <button type="submit" class="flex-1 py-3 bg-green-600 text-white rounded-xl font-bold hover:bg-green-700 shadow-lg">Confirm Registration</button>
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
    <select v-model="editForm.status" class="w-full mt-1 border-gray-300 rounded-lg text-sm">
        <option value="Working">Working</option>
        <option value="Under Repair">Under Repair</option>
        <option value="Maintenance">Maintenance</option>
        <option value="Standby">Standby</option>
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
