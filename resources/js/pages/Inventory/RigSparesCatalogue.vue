<template>
    <div class="p-6 bg-slate-50 min-h-screen">
        <div class="max-w-7xl mx-auto mb-8 flex flex-col md:flex-row justify-between items-start md:items-end gap-4">
            <div>
                <h1 class="text-4xl font-black italic uppercase tracking-tighter text-slate-900">
                    {{ rig?.name || 'Machine' }} <span class="text-indigo-600">Catalogue</span>
                </h1>
                <p class="text-slate-500 font-bold uppercase text-[10px] tracking-widest mt-2">
                    Technical Asset Management & Spares Traceability
                </p>
            </div>

            <div class="relative">
                <input v-model="searchQuery" type="text" placeholder="Search Serial or Name..."
                    class="bg-white border-none shadow-sm rounded-2xl px-6 py-3 text-xs w-full md:w-64 focus:ring-2 focus:ring-indigo-500 font-bold">
            </div>
        </div>

        <div class="max-w-7xl mx-auto">
            <div v-if="!inventory || inventory.length === 0"
                class="text-center py-20 bg-white rounded-[32px] border-2 border-dashed border-slate-200">
                <div class="text-4xl mb-4 opacity-20">📦</div>
                <p class="text-slate-400 font-bold uppercase text-[10px] tracking-widest">
                    No inventory data available for this rig
                </p>
            </div>

            <div v-else class="space-y-12">
                <div v-for="(parts, group) in groupedInventory" :key="group"
                    class="bg-white rounded-[32px] shadow-sm border border-slate-100 overflow-hidden">

                    <div class="p-6 border-b border-slate-50 bg-slate-50/50 flex justify-between items-center">
                        <h2
                            class="text-sm font-black uppercase text-slate-900 italic tracking-tighter flex items-center gap-2">
                            {{ group }}
                            <span v-if="group === 'Turret'"
                                class="not-italic bg-amber-100 text-amber-600 text-[8px] px-2 py-0.5 rounded-full uppercase tracking-widest font-black">
                                Critical System
                            </span>
                        </h2>
                        <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{{ parts.length }}
                            Items</span>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr
                                    class="text-[10px] uppercase font-black text-slate-400 tracking-widest border-b border-slate-50">
                                    <th class="px-8 py-4">Component Details</th>
                                    <th class="px-8 py-4">Status</th>
                                    <th class="px-8 py-4 text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="part in parts" :key="part.id"
                                    class="border-b border-slate-50 hover:bg-slate-50/50 transition-colors group">
                                    <td class="px-8 py-5">
                                        <div class="flex flex-col">
                                            <span
                                                class="text-sm font-black text-slate-800 uppercase tracking-tight group-hover:text-indigo-600 transition-colors cursor-pointer"
                                                @click="viewHistory(part)">
                                                {{ part.name }}
                                            </span>
                                            <span class="text-[10px] font-mono text-slate-400 font-bold">{{
                                                part.serial_number }}</span>
                                        </div>
                                    </td>
                                    <td class="px-8 py-5">
                                        <span
                                            class="px-3 py-1 rounded-full text-[9px] font-black uppercase tracking-widest bg-emerald-100 text-emerald-600">
                                            {{ part.status || 'Working' }}
                                        </span>
                                    </td>
                                    <td class="px-8 py-5 text-right">
                                        <div class="flex justify-end gap-2">
                                            <button @click="openLogEntry(part)"
                                                class="bg-indigo-50 text-indigo-600 text-[9px] font-black px-3 py-1.5 rounded-xl uppercase hover:bg-indigo-600 hover:text-white transition-all">
                                                + Log Work
                                            </button>
                                            <button @click="viewHistory(part)"
                                                class="bg-slate-100 text-slate-500 text-[9px] font-black px-3 py-1.5 rounded-xl uppercase hover:bg-slate-900 hover:text-white transition-all">
                                                History
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <PartHistoryModal v-if="historyModalOpen && selectedPart" :show="historyModalOpen"
            :serialNumber="selectedPart.serial_number" @close="historyModalOpen = false" />

        <LogEntryModal v-if="selectedPart" :show="logModalOpen" :part="selectedPart" @close="logModalOpen = false"
            @saved="refreshData" />
    </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import PartHistoryModal from './PartHistoryModal.vue';
import LogEntryModal from './LogEntryModal.vue';

const props = defineProps({
    rig: Object,
    inventory: Array, // This must be an Array type
    sparesGrouped: Object,
    warehouseSpares: Array,
    existingGroups: Array
});

const searchQuery = ref('');
const historyModalOpen = ref(false);
const logModalOpen = ref(false);
const selectedPart = ref(null);

// FIXED: Computed property with Safety Guards
const groupedInventory = computed(() => {
    // 1. Safety check: If inventory is missing, return empty object
    if (!props.inventory) return {};

    // 2. Filter logic with string safety
    const filtered = props.inventory.filter(p => {
        const s = searchQuery.value.toLowerCase();
        const name = (p.name || '').toLowerCase();
        const sn = (p.serial_number || '').toLowerCase();
        return name.includes(s) || sn.includes(s);
    });

    // 3. Grouping logic
    return filtered.reduce((acc, part) => {
        const group = part.functional_group || 'General Spares';
        if (!acc[group]) acc[group] = [];
        acc[group].push(part);
        return acc;
    }, {});
});

const viewHistory = (part) => {
    selectedPart.value = part;
    historyModalOpen.value = true;
};

const openLogEntry = (part) => {
    selectedPart.value = part;
    logModalOpen.value = true;
};

const refreshData = () => {
    // This will depend on your Inertia reload logic
    console.log("Maintenance log saved. View refreshed.");
};
</script>

<style scoped>
/* Optional: Smooth entry for the groups */
.space-y-12>div {
    animation: fadeIn 0.4s ease-out forwards;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}
</style>
