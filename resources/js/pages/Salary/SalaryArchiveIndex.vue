<script setup>
import { ref } from 'vue';
import { router, Head, Link } from '@inertiajs/vue3';

const props = defineProps({
    history: { type: Array, default: () => [] },
    filters: { type: Object, default: () => ({ year: new Date().getFullYear() }) }
});

const selectedYear = ref(props.filters.year);
const years = [2024, 2025, 2026];

const changeYear = () => {
    router.get(route('salary.archive.index'), { year: selectedYear.value }, { preserveState: true });
};
</script>

<template>
    <Head title="Salary Archive" />

    <div class="min-h-screen bg-gray-100 p-6 font-sans text-slate-900">
        <div class="max-w-6xl mx-auto">

            <div class="flex items-center justify-between mb-8">
                <Link :href="route('salary.index')" class="flex items-center gap-2 text-slate-400 hover:text-indigo-600 transition-colors group">
                    <span class="text-lg group-hover:-translate-x-1 transition-transform">←</span>
                    <span class="text-[10px] font-black uppercase tracking-widest italic">Back to Live Dashboard</span>
                </Link>

                <div class="flex items-center gap-3 bg-white px-4 py-2 rounded-xl border border-slate-200 shadow-sm">
                    <span class="text-[9px] font-black text-slate-400 uppercase italic">Archival Year</span>
                    <select v-model="selectedYear" @change="changeYear" class="bg-transparent border-none text-xs font-black focus:ring-0 cursor-pointer p-0">
                        <option v-for="y in years" :key="y" :value="y">{{ y }}</option>
                    </select>
                </div>
            </div>

            <div class="mb-10 text-center">
                <h1 class="text-4xl font-black text-slate-900 uppercase tracking-tighter italic">Salary <span class="text-indigo-600">Archive</span></h1>
                <p class="text-[10px] font-bold text-slate-400 uppercase tracking-[0.5em] mt-2 italic">LPC Payroll Historical Records</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <div v-for="record in history" :key="record.month"
                     class="group bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-xl hover:border-indigo-500 transition-all cursor-pointer overflow-hidden flex flex-col">

                    <div class="p-6 border-b border-slate-50 bg-slate-50/50 group-hover:bg-indigo-50 transition-colors">
                        <h2 class="text-xl font-black text-slate-800 uppercase italic tracking-tight group-hover:text-indigo-700">{{ record.month }}</h2>
                        <p class="text-[9px] font-bold text-slate-400 uppercase tracking-widest mt-1">{{ record.year }}</p>
                    </div>

                    <div class="p-6 space-y-4 flex-1">
                        <div>
                            <p class="text-[8px] font-black text-slate-400 uppercase italic mb-1">Net Payout</p>
                            <p class="text-lg font-black text-slate-900 tracking-tight">৳{{ record.total_payout.toLocaleString() }}</p>
                        </div>
                        <div class="flex justify-between items-center pt-4 border-t border-slate-50">
                            <span class="bg-emerald-100 text-emerald-700 text-[8px] px-2 py-1 rounded font-black uppercase italic">Completed</span>
                            <span class="text-[9px] font-bold text-slate-300 font-mono">#{{ record.month.substring(0,3) }}-{{ record.year }}</span>
                        </div>
                    </div>

                    <Link :href="route('salary.archive.show', { month: record.month, year: record.year })"
                          class="py-4 bg-slate-900 text-white text-center text-[10px] font-black uppercase tracking-[0.2em] group-hover:bg-indigo-600 transition-colors">
                        Open Statement
                    </Link>
                </div>
            </div>

            <div v-if="history.length === 0" class="mt-20 text-center p-20 bg-white rounded-[40px] border border-dashed border-slate-300">
                <div class="text-4xl mb-4">📂</div>
                <p class="text-slate-400 font-black uppercase tracking-[0.3em] text-xs">No entries found for {{ selectedYear }}</p>
            </div>

        </div>
    </div>
</template>
