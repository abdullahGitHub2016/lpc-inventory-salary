<script setup>
import { ref } from 'vue';
import { router, Head, Link } from '@inertiajs/vue3';

const props = defineProps({
    // 'history' comes from SalaryController@archiveIndex
    history: { type: Array, default: () => [] },
    filters: { type: Object, default: () => ({ year: new Date().getFullYear() }) }
});

const selectedYear = ref(props.filters.year);
const years = [2024, 2025, 2026];

// --- CHANGE YEAR FILTER ---
const changeYear = () => {
    router.get(route('salary.archive.index'), { year: selectedYear.value }, { preserveState: true });
};

// --- DELETE ARCHIVE LOGIC ---
const deleteArchive = (month, year) => {
    if (confirm(`CRITICAL WARNING: This will permanently delete the entire salary archive for ${month} ${year}. This action cannot be undone. Continue?`)) {
        router.delete(route('salary.archive.destroy', { month, year }), {
            onSuccess: () => alert('Archive deleted successfully.'),
            onError: (errors) => alert('Error: ' + Object.values(errors)[0])
        });
    }
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
                    <span class="text-[9px] font-black text-slate-400 uppercase italic">Filter Year:</span>
                    <select v-model="selectedYear" @change="changeYear"
                        class="bg-transparent border-none text-[10px] font-black uppercase tracking-widest outline-none focus:ring-0 cursor-pointer text-indigo-600">
                        <option v-for="y in years" :key="y" :value="y">{{ y }}</option>
                    </select>
                </div>
            </div>

            <div class="mb-10 text-center md:text-left">
                <h1 class="text-4xl font-black italic tracking-tighter text-slate-900 uppercase">
                    Payroll <span class="text-indigo-600">Archives</span>
                </h1>
                <p class="text-[10px] font-bold text-slate-400 uppercase tracking-[0.4em] mt-2">Historical Records for {{ selectedYear }}</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">

                <div v-for="record in history" :key="record.id"
                    class="group bg-white rounded-[40px] overflow-hidden border border-slate-200 shadow-sm hover:shadow-2xl transition-all flex flex-col relative">

                    <button @click="deleteArchive(record.month, record.year)"
                            class="absolute top-4 right-4 p-2 bg-red-50 text-red-500 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-500 hover:text-white z-10 transition-all">
                        🗑️
                    </button>

                    <div class="p-10 flex-1">
                        <div class="flex justify-between items-start mb-6">
                            <div>
                                <h3 class="text-2xl font-black text-slate-900 uppercase italic tracking-tighter">
                                    {{ record.month }}
                                </h3>
                                <p class="text-[10px] font-bold text-indigo-600 uppercase tracking-[0.3em] italic">
                                    Year {{ record.year }}
                                </p>
                            </div>
                        </div>

                        <div class="space-y-4">
                            <div>
                                <p class="text-[8px] font-black text-slate-400 uppercase italic mb-1 tracking-widest">Net Payout</p>
                                <p class="text-2xl font-black text-slate-900 tracking-tight italic">৳{{ record.total_payout.toLocaleString() }}</p>
                            </div>

                            <div class="flex justify-between items-center pt-4 border-t border-slate-50">
                                <span class="bg-emerald-100 text-emerald-700 text-[8px] px-2 py-1 rounded font-black uppercase italic">Closed</span>
                                <span class="text-[9px] font-bold text-slate-300 font-mono tracking-tighter">
                                    #{{ record.month.substring(0,3).toUpperCase() }}-{{ record.year }}
                                </span>
                            </div>
                        </div>
                    </div>

                    <Link :href="route('salary.archive.show', { month: record.month, year: record.year })"
                          class="py-5 bg-slate-900 text-white text-center text-[10px] font-black uppercase tracking-[0.2em] group-hover:bg-indigo-600 transition-colors">
                        Open Statement
                    </Link>
                </div>
                </div>

            <div v-if="history.length === 0"
                 class="mt-20 text-center p-20 bg-white rounded-[40px] border-2 border-dashed border-slate-200">
                <div class="text-5xl mb-6 opacity-20">📂</div>
                <h3 class="text-slate-400 font-black uppercase tracking-[0.3em] text-xs">No records found for {{ selectedYear }}</h3>
                <p class="text-slate-300 text-[10px] font-bold uppercase italic mt-2">Close a month from the live dashboard to create an archive</p>
            </div>

        </div>
    </div>
</template>

<style scoped>
/* Optional: ensures smooth hover transitions for the cards */
.group:hover {
    transform: translateY(-5px);
}
</style>
