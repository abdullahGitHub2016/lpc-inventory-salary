<script setup>
import { ref, computed } from 'vue';
import { useForm, Link, router } from '@inertiajs/vue3';
import PartHistoryModal from './PartHistoryModal.vue';
import LogEntryModal from './LogEntryModal.vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    rig: Object,
    inventory: Array,
    sparesGrouped: Object,
    warehouseSpares: Array,
    existingGroups: Array
});

// --- STATE ---
const searchQuery = ref('');
const showAddSpareModal = ref(false);
const historyModalOpen = ref(false);
const logModalOpen = ref(false);
const selectedPart = ref(null);

// --- FORMS ---
const addSpareForm = useForm({
    new_part_name: '',
    part_number: '',
    functional_group: 'General Spares',
});

// --- METHODS ---
const submitAddSpare = () => {
    addSpareForm.post(route('inventory.rig.add-spare', props.rig.id), {
        onSuccess: () => {
            showAddSpareModal.value = false;
            addSpareForm.reset();
        },
        preserveScroll: true
    });
};

const deletePart = (part) => {
    if (confirm(`Are you sure you want to PERMANENTLY delete ${part.name}?`)) {
        router.delete(route('inventory.destroy', part.id), {
            preserveScroll: true
        });
    }
};

const viewHistory = (part) => {
    selectedPart.value = part;
    historyModalOpen.value = true;
};

const openLogEntry = (part) => {
    selectedPart.value = part;
    logModalOpen.value = true;
};

// --- FILTERED GROUPING ---
const groupedInventory = computed(() => {
    if (!props.inventory) return {};

    const filtered = props.inventory.filter(p => {
        const s = searchQuery.value.toLowerCase();
        return (p.name || '').toLowerCase().includes(s) ||
               (p.serial_number || '').toLowerCase().includes(s);
    });

    // If filter results in 0 items, reduce returns {}, which triggers the "No Match Found" UI
    return filtered.reduce((acc, part) => {
        const group = part.functional_group || 'General Spares';
        if (!acc[group]) acc[group] = [];
        acc[group].push(part);
        return acc;
    }, {});
});

// Ensure router is imported at the top
const deleteDocument = (documentId) => {
    if (confirm('Are you sure you want to permanently delete this document?')) {
        // This assumes you have a route named 'inventory.documents.destroy'
        router.delete(route('inventory.documents.delete', documentId), {
            preserveScroll: true,
            onSuccess: () => {
                console.log("Document removed");
            }
        });
    }
};
</script>

<template>
    <AuthenticatedLayout>
    <div class="min-h-screen bg-slate-50 p-4 md:p-8">
        <div class="max-w-7xl mx-auto">

            <div class="bg-white p-8 rounded-[3rem] shadow-sm border border-slate-200 mb-8">
                <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <Link :href="route('inventory.fleet')"
                                class="text-[10px] font-black uppercase text-indigo-500 hover:underline">← Machine</Link>
                            <span class="text-slate-300">/</span>
                            <span class="text-[10px] font-black uppercase text-slate-400 italic">Catalogue</span>
                        </div>
                        <h1 class="text-4xl font-black uppercase italic text-slate-900 leading-tight">{{ rig.name }}
                        </h1>
                        <p class="text-xs font-mono font-bold text-slate-400 mt-1 uppercase tracking-tighter">S/N: {{
                            rig.serial_number }}</p>
                    </div>
                    <div>
                        <button @click="showAddSpareModal = true"
                            class="bg-indigo-600 text-white px-8 py-4 rounded-2xl font-black text-[11px] uppercase shadow-xl shadow-indigo-100">
                            + Install Part
                        </button>
                    </div>
                </div>

                <div v-for="doc in rig.documents" :key="doc.id"
                    class="flex items-center gap-3 bg-slate-50 border border-slate-200 px-4 py-3 rounded-2xl group hover:border-red-200 transition-all relative">
                    <div class="text-2xl">📄</div>
                    <div class="flex flex-col pr-8"> <span
                            class="text-[10px] font-black uppercase text-slate-700 leading-tight">
                            {{ doc.file_name }}
                        </span>
                        <a :href="doc.file_path" target="_blank"
                            class="text-[9px] font-bold text-indigo-500 hover:text-indigo-700 uppercase underline mt-1">
                            View / Download
                        </a>
                    </div>

                    <button @click="deleteDocument(doc.id)"
                        class="absolute top-2 right-2 text-slate-300 hover:text-red-500 transition-colors"
                        title="Delete Document">
                        <span class="text-xs">✕</span>
                    </button>
                </div>
            </div>

            <div v-if="inventory && inventory.length > 0" class="relative">
                <input v-model="searchQuery" type="text" placeholder="Filter parts..."
                    class="w-full md:w-96 bg-white border-slate-200 rounded-2xl px-6 py-4 text-sm font-medium shadow-sm focus:ring-2 focus:ring-indigo-500 transition-all" />
            </div>
            <div class="max-w-7xl mx-auto">
                <div v-if="!inventory || inventory.length === 0"
                    class="text-center py-20 bg-white rounded-[32px] border-2 border-dashed border-slate-200">
                    <div class="text-5xl mb-4 opacity-30">🛠️</div>
                    <h3 class="text-slate-900 font-black uppercase italic tracking-tighter text-lg">Empty Catalogue</h3>
                    <p class="text-slate-400 font-bold uppercase text-[10px] tracking-widest mt-2 px-6">
                        There are currently no spare parts registered or installed on this rig.
                    </p>
                    <button @click="showAddSpareModal = true"
                        class="mt-6 text-indigo-600 font-black text-[10px] uppercase underline">
                        + Click here to install the first part
                    </button>
                </div>

                <div v-else-if="Object.keys(groupedInventory).length === 0"
                    class="text-center py-20 bg-white rounded-[32px] border border-slate-100 shadow-sm">
                    <div class="text-4xl mb-4">🔍</div>
                    <h3 class="text-slate-900 font-black uppercase italic tracking-tighter">No Match Found</h3>
                    <p class="text-slate-400 font-bold uppercase text-[10px] tracking-widest mt-2">
                        No components match your search: <span class="text-indigo-500">"{{ searchQuery }}"</span>
                    </p>
                    <button @click="searchQuery = ''"
                        class="mt-4 text-slate-400 font-black text-[9px] uppercase border border-slate-200 px-4 py-2 rounded-full hover:bg-slate-50">
                        Clear Search
                    </button>
                </div>

                <div v-else class="space-y-12">
                </div>
            </div>
            <div v-for="(parts, group) in groupedInventory" :key="group" class="mb-12">
                <h2 class="text-xs font-black uppercase tracking-[0.2em] text-slate-400 italic mb-6 ml-4">{{ group }}
                </h2>
                <div class="bg-white rounded-[2.5rem] shadow-sm border border-slate-200 overflow-hidden">
                    <table class="w-full text-left">
                        <thead class="bg-slate-50/50 border-b border-slate-100">
                            <tr>
                                <th class="px-8 py-5 text-[10px] font-black text-slate-400 uppercase italic">Component
                                </th>
                                <th class="px-8 py-5 text-[10px] font-black text-slate-400 uppercase italic">Serial
                                    Number</th>
                                <th class="px-8 py-5 text-right text-[10px] font-black text-slate-400 uppercase italic">
                                    Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-50">
                            <tr v-for="part in parts" :key="part.id" class="hover:bg-slate-50/50 group">
                                <td class="px-8 py-6 font-black text-slate-800 text-sm uppercase">{{ part.name }}</td>
                                <td class="px-8 py-6 font-mono text-xs font-bold text-indigo-500">{{ part.serial_number
                                    }}</td>
                                <td class="px-8 py-6 text-right">
                                    <div class="flex justify-end gap-3 items-center">
                                        <button @click="openLogEntry(part)"
                                            class="bg-indigo-50 text-indigo-600 text-[9px] font-black px-4 py-2 rounded-xl uppercase hover:bg-indigo-600 hover:text-white transition-all">+
                                            Log</button>
                                        <button @click="viewHistory(part)"
                                            class="text-slate-400 hover:text-slate-900 transition-colors">🕒</button>
                                        <button @click="deletePart(part)"
                                            class="text-red-300 hover:text-red-600 transition-colors">🗑️</button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div v-if="groupedInventory && Object.keys(groupedInventory).length === 0 && searchQuery"
                class="text-center py-10">
                <p class="text-slate-400 font-bold uppercase text-[10px]">No results matching "{{ searchQuery }}"</p>
            </div>
        </div>

        <div v-if="showAddSpareModal"
            class="fixed inset-0 bg-slate-900/80 backdrop-blur-sm z-[100] flex items-center justify-center p-4">
            <div class="bg-white rounded-[3rem] p-10 w-full max-w-xl shadow-2xl">
                <h3 class="text-2xl font-black uppercase italic mb-8 text-slate-900">Install New Part</h3>
                <form @submit.prevent="submitAddSpare" class="grid grid-cols-2 gap-6">
                    <div class="col-span-2">
                        <label class="text-[10px] font-black uppercase text-slate-400 ml-4 mb-1 block">Name</label>
                        <input v-model="addSpareForm.new_part_name" type="text"
                            class="w-full bg-slate-50 border-none rounded-2xl p-4 text-sm font-bold" required />
                    </div>
                    <div>
                        <label class="text-[10px] font-black uppercase text-slate-400 ml-4 mb-1 block">S/N</label>
                        <input v-model="addSpareForm.part_number" type="text"
                            class="w-full bg-slate-50 border-none rounded-2xl p-4 text-sm font-bold" required />
                    </div>
                    <div>
                        <label class="text-[10px] font-black uppercase text-slate-400 ml-4 mb-1 block">Group</label>
                        <select v-model="addSpareForm.functional_group"
                            class="w-full bg-slate-50 border-none rounded-2xl p-4 text-sm font-bold">
                            <option value="General Spares">General Spares</option>
                            <option v-for="group in existingGroups" :key="group" :value="group">{{ group }}</option>
                            <option value="Engine System">Engine System</option>
                            <option value="Hydraulic System">Hydraulic System</option>
                        </select>
                    </div>
                    <div class="col-span-2 flex gap-4 mt-6">
                        <button type="button" @click="showAddSpareModal = false"
                            class="flex-1 py-4 bg-slate-100 rounded-2xl font-black uppercase text-[10px]">Cancel</button>
                        <button type="submit"
                            class="flex-1 py-4 bg-indigo-600 text-white rounded-2xl font-black uppercase text-[10px]">Confirm
                            Installation</button>
                    </div>
                </form>
            </div>
        </div>

        <PartHistoryModal v-if="historyModalOpen && selectedPart" :show="historyModalOpen"
            :serialNumber="selectedPart.serial_number" @close="historyModalOpen = false" />
        <LogEntryModal v-if="selectedPart" :show="logModalOpen" :part="selectedPart" @close="logModalOpen = false" />
    </div>
    </AuthenticatedLayout>
</template>
