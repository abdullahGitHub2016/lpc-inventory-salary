<script setup>
import { ref, watch } from 'vue';
import { useForm, Head, Link, router } from '@inertiajs/vue3';
import { debounce } from 'lodash';

const props = defineProps({
    equipment: Object,
    sites: Array,
    employees: Array
});

// --- SEARCH STATE & LOGIC ---
const searchQuery = ref(new URLSearchParams(window.location.search).get('search') || '');

watch(searchQuery, debounce((value) => {
    router.get(route('inventory.fleet'), { search: value }, {
        preserveState: true,
        replace: true,
        preserveScroll: true
    });
}, 300));

// --- MODAL STATE ---
const showLogsModal = ref(false);
const showLogForm = ref(false);
const selectedItem = ref(null);

// --- REACTIVE SYNC (CRITICAL FIX) ---
// This watches for any background refresh of the equipment list (e.g., after a 303 redirect).
// It ensures that if a modal is open, its content updates immediately with fresh data.
// Add deep: true to ensure nested changes in the equipment array are caught
watch(() => props.equipment.data, (newData) => {
    if (selectedItem.value) {
        // Find the fresh version of the currently open item in the new data
        const freshData = newData.find(item => item.id === selectedItem.value.id);
        if (freshData) {
            selectedItem.value = freshData; // This refreshes the modal UI
        }
    }
}, { deep: true });

const logForm = useForm({
    equipment_id: '',
    mechanic_id: '',
    service_date: new Date().toISOString().split('T')[0],
    running_hours: '',
    service_type: '',
    parts_replaced: '',
});

// --- METHODS ---
const openHistory = (item) => {
    selectedItem.value = item;
    showLogsModal.value = true;
};

const handleTransfer = (id, event) => {
    const siteId = event.target.value;
    if (!siteId) return;

    router.put(`/inventory/transfer/${id}`, {
        to_site_id: siteId
    }, {
        preserveScroll: true,
        onSuccess: () => {
            // Force the dropdown back to "Move..."
            event.target.value = "";

            // Re-sync the modal if it's open for this specific item
            if (selectedItem.value && selectedItem.value.id === id) {
                const updated = props.equipment.data.find(i => i.id === id);
                if (updated) {
                    selectedItem.value = updated;
                }
            }
        }
    });
};
const getStatusBadge = (status) => {
    const map = {
        'Working': 'bg-green-100 text-green-700 border-green-200',
        'In Stock': 'bg-blue-100 text-blue-700 border-blue-200',
        'Maintenance': 'bg-amber-100 text-amber-700 border-amber-200'
    };
    return map[status] || 'bg-gray-100 text-gray-700 border-gray-200';
};

const submitLog = () => {
    logForm.equipment_id = selectedItem.value.id;

    logForm.post(route('inventory.service-logs.store'), {
        preserveScroll: true,
        onSuccess: () => {
            logForm.reset(['running_hours', 'service_type', 'parts_replaced', 'mechanic_id']);
            showLogForm.value = false;
        },
    });
};

const unlinkSpare = (spareId) => {
    if (confirm('Move this item back to the Warehouse?')) {
        // Matches the POST method for unlinking
        router.post(`/inventory/unlink-spare/${spareId}`, {}, {
            preserveScroll: true
        });
    }
};

</script>

<template>

    <Head title="Fleet Management" />
    <div class="min-h-screen bg-gray-50 p-4 md:p-8">
        <div class="max-w-7xl mx-auto">
            <div
                class="bg-white p-6 rounded-3xl shadow-sm border border-gray-200 mb-6 flex flex-col md:flex-row justify-between items-center gap-4">
                <h1 class="text-2xl font-black uppercase italic text-gray-900">Active Fleet</h1>
                <div class="relative w-full md:w-64">
                    <input v-model="searchQuery" placeholder="Search rigs..."
                        class="w-full rounded-xl border-gray-200 text-sm px-4 py-2 focus:ring-2 focus:ring-indigo-500" />
                </div>
            </div>

            <div class="bg-white rounded-3xl shadow-sm border border-gray-200 overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-gray-50 border-b text-[10px] font-black uppercase text-gray-400">
                            <tr>
                                <th class="px-6 py-5">Machine Details</th>
                                <th class="px-6 py-5">Current Site</th>
                                <th class="px-6 py-5">Status</th>
                                <th class="px-6 py-5 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm">
                            <tr v-for="item in equipment.data" :key="item.id"
                                class="hover:bg-gray-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <div class="font-bold text-gray-800">{{ item.name }}</div>
                                    <div class="text-[10px] font-mono text-indigo-500 font-bold uppercase">{{
                                        item.serial_number }}</div>
                                    <div v-if="item.spares?.length > 0" class="mt-1">
                                        <span
                                            class="text-[8px] bg-indigo-50 text-indigo-600 px-2 py-0.5 rounded-full font-bold uppercase border border-indigo-100">
                                            {{ item.spares.length }} Spares Attached
                                        </span>
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-xs block mb-1 font-bold text-gray-700">{{
                                        item.current_site?.location_name || 'In Transit' }}</span>
                                    <select @change="handleTransfer(item.id, $event)"
                                        class="text-[9px] border-none bg-gray-100 rounded-lg p-1 focus:ring-1 focus:ring-indigo-400">
                                        <option value="">Move...</option>
                                        <option v-for="site in sites" :key="site.id" :value="site.id">{{
                                            site.location_name }}</option>
                                    </select>
                                </td>
                                <td class="px-6 py-4">
                                    <span :class="getStatusBadge(item.status)"
                                        class="px-3 py-1 rounded-full text-[9px] font-black uppercase border shadow-sm">
                                        {{ item.status }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <!-- <button @click="openHistory(item)" class="text-indigo-600 font-black text-[10px] uppercase underline hover:text-indigo-800 transition-colors">History</button> -->
                                    <Link :href="route('inventory.rig.spares', item.id)"
                                        class="text-emerald-600 font-black text-[10px] uppercase underline mx-2">
                                        View Spares
                                    </Link>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div v-if="equipment.links.length > 3" class="flex justify-center gap-1 py-8">
                <Link v-for="(link, k) in equipment.links" :key="k" :href="link.url || '#'" v-html="link.label"
                    class="px-4 py-2 rounded-xl text-xs font-bold border transition-all"
                    :class="[link.active ? 'bg-indigo-600 text-white shadow-md' : 'bg-white text-gray-600', !link.url ? 'opacity-30 cursor-not-allowed' : 'hover:border-indigo-300']" />
            </div>
        </div>
    </div>

    <div v-if="showLogsModal && selectedItem"
        class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 p-4 backdrop-blur-sm">
        <div
            class="bg-white rounded-[2rem] shadow-2xl w-full max-w-2xl max-h-[85vh] overflow-y-auto p-8 border border-white/20">
            <div class="flex justify-between items-center mb-8 border-b pb-4">
                <div>
                    <h3 class="text-xl font-black uppercase italic text-gray-900">{{ selectedItem.name }}</h3>
                    <p class="text-[10px] font-mono text-indigo-500 font-bold uppercase">S/N: {{
                        selectedItem.serial_number }}</p>
                </div>
                <button @click="showLogsModal = false"
                    class="text-3xl font-light hover:text-red-500 transition-colors">&times;</button>
            </div>

            <div class="mb-10">
                <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4 italic">Attached Spares
                    ({{ selectedItem.spares?.length || 0 }})</h4>
                <div v-if="selectedItem.spares?.length > 0" class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <div v-for="spare in selectedItem.spares" :key="spare.id"
                        class="p-4 bg-indigo-50/50 border border-indigo-100 rounded-2xl flex justify-between items-center">
                        <div>
                            <p class="font-bold text-xs text-gray-800">{{ spare.name }}</p>
                            <p class="text-[9px] font-mono text-indigo-400 font-bold uppercase">{{ spare.serial_number
                                }}</p>
                        </div>
                        <button @click="unlinkSpare(spare.id)"
                            class="text-[9px] font-black text-red-500 uppercase underline hover:text-red-700">Unlink</button>
                    </div>
                </div>
                <div v-else
                    class="text-center py-6 bg-gray-50 rounded-3xl border border-dashed text-gray-400 text-[10px] font-bold uppercase">
                    No Spares Attached
                </div>
            </div>

            <div class="mb-6">
                <div class="flex justify-between items-center mb-4">
                    <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest italic">Service History
                    </h4>
                    <button @click="showLogForm = !showLogForm"
                        class="bg-indigo-600 text-white px-3 py-1 rounded-lg text-[9px] font-black uppercase tracking-tighter hover:bg-indigo-700 shadow-md transition-all">
                        {{ showLogForm ? 'Cancel' : '+ Add Record' }}
                    </button>
                </div>

                <div v-if="showLogForm"
                    class="bg-gray-50 p-6 rounded-3xl border border-dashed border-indigo-200 mb-6 shadow-inner">
                    <form @submit.prevent="submitLog" class="grid grid-cols-2 gap-4">
                        <div class="col-span-1">
                            <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Date</label>
                            <input v-model="logForm.service_date" type="date"
                                class="w-full border-gray-200 rounded-xl text-xs focus:ring-indigo-500" required />
                        </div>
                        <div class="col-span-1">
                            <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Mechanic</label>
                            <select v-model="logForm.mechanic_id"
                                class="w-full border-gray-200 rounded-xl text-xs focus:ring-indigo-500" required>
                                <option value="">Select Mechanic</option>
                                <option v-for="emp in employees" :key="emp.id" :value="emp.id">{{ emp.name }}</option>
                            </select>
                        </div>
                        <div class="col-span-1">
                            <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Running Hours</label>
                            <input v-model="logForm.running_hours" type="number" step="0.1"
                                class="w-full border-gray-200 rounded-xl text-xs focus:ring-indigo-500" required />
                        </div>
                        <div class="col-span-1">
                            <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Service Type</label>
                            <input v-model="logForm.service_type" placeholder="e.g. 1000H Service"
                                class="w-full border-gray-200 rounded-xl text-xs focus:ring-indigo-500" required />
                        </div>
                        <div class="col-span-2">
                            <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Maintenance Details</label>
                            <textarea v-model="logForm.parts_replaced"
                                placeholder="Describe parts replaced or work done..."
                                class="w-full border-gray-200 rounded-xl text-xs focus:ring-indigo-500"
                                rows="2"></textarea>
                        </div>
                        <button type="submit"
                            class="col-span-2 py-3 bg-indigo-600 text-white rounded-xl font-black uppercase text-[10px] hover:bg-indigo-700 shadow-lg transition-all"
                            :disabled="logForm.processing">
                            {{ logForm.processing ? 'Saving...' : 'Save Record' }}
                        </button>
                    </form>
                </div>

                <div v-if="(selectedItem.maintenance_logs || selectedItem.maintenanceLogs)?.length > 0"
                    class="space-y-4">
                    <div v-for="log in (selectedItem.maintenance_logs || selectedItem.maintenanceLogs)" :key="log.id"
                        class="p-5 border rounded-3xl bg-gray-50 hover:bg-white transition-colors border-gray-100 shadow-sm">
                        <div class="flex justify-between font-black text-[10px] mb-2 text-gray-400 uppercase">
                            <span>{{ log.service_date }}</span>
                            <span class="text-emerald-500 font-bold">{{ log.running_hours }} HRS</span>
                        </div>
                        <p class="font-black text-gray-800 text-sm uppercase mb-1">{{ log.service_type }}</p>
                        <p class="text-xs text-gray-500 leading-relaxed">{{ log.parts_replaced }}</p>
                        <p v-if="log.mechanic"
                            class="text-[9px] font-bold text-indigo-400 mt-2 uppercase italic tracking-wider">
                            By: {{ log.mechanic.name }}
                        </p>
                    </div>
                </div>
                <p v-else
                    class="text-xs italic text-gray-400 text-center py-8 bg-gray-50/50 rounded-2xl border border-dashed">
                    No service records found for this unit.</p>
            </div>
        </div>
    </div>
</template>
