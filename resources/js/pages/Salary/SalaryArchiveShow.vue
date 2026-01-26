<script setup>
import { ref, computed } from 'vue';
import { Head, Link } from '@inertiajs/vue3';

const props = defineProps({
    monthData: {
        type: Object,
        default: () => ({
            month: 'December',
            year: 2025,
            id: 'REF-9921',
            employees: []
        })
    },
});

const searchQuery = ref('');

// --- SEARCH LOGIC ---
const filteredEmployees = computed(() => {
    if (!searchQuery.value) return props.monthData.employees;

    const query = searchQuery.value.toLowerCase().trim();
    return props.monthData.employees.filter(emp =>
        emp.name.toLowerCase().includes(query) ||
        emp.employee_id.toLowerCase().includes(query)
    );
});

const grandTotal = computed(() => {
    return props.monthData.employees.reduce((acc, emp) => acc + parseFloat(emp.net_payable), 0);
});

const printSheet = () => window.print();
</script>

<template>
    <Head :title="`Sheet: ${monthData.month} ${monthData.year}`" />

    <div class="min-h-screen bg-gray-50 p-4 md:p-10 font-sans text-slate-900 print:bg-white print:p-0">
        <div class="max-w-6xl mx-auto">

            <div class="flex items-center justify-between mb-6 print:hidden">
                <Link :href="route('salary.archive.index')" class="flex items-center gap-2 text-slate-400 hover:text-indigo-600 transition-all group">
                    <span class="text-lg group-hover:-translate-x-1 transition-transform">←</span>
                    <span class="text-[10px] font-black uppercase tracking-widest italic">Archives Index</span>
                </Link>

                <div class="flex gap-3">
                    <button @click="printSheet" class="bg-indigo-600 text-white px-8 py-3 rounded-xl font-black text-[10px] uppercase tracking-widest shadow-xl shadow-indigo-100 hover:bg-indigo-700 transition-all">
                        Print Sheet 🖨️
                    </button>
                </div>
            </div>

            <div class="bg-white rounded-t-[32px] border-x border-t border-slate-200 p-10 print:p-8">
                <div class="flex flex-col md:flex-row justify-between items-center gap-6">
                    <div>
                        <h1 class="text-3xl font-black text-slate-900 uppercase italic tracking-tighter leading-none">LPC Payroll Report</h1>
                        <p class="text-[10px] font-black text-indigo-600 uppercase tracking-[0.4em] mt-3 italic">{{ monthData.month }} {{ monthData.year }} • Ref: {{ monthData.id }}</p>
                    </div>

                    <div class="w-full md:w-72 print:hidden relative">
                        <input
                            v-model="searchQuery"
                            type="text"
                            placeholder="Find employee..."
                            class="w-full bg-slate-50 border border-slate-200 rounded-xl px-5 py-3 text-xs font-bold focus:ring-2 focus:ring-indigo-500 outline-none transition-all pr-10"
                        />
                        <span class="absolute right-4 top-3.5 opacity-20">🔍</span>
                    </div>
                </div>
            </div>

            <div class="bg-white border-x border-slate-200 overflow-hidden min-h-[400px]">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50 border-y border-slate-100">
                            <th class="px-10 py-5 text-[10px] font-black text-slate-500 uppercase tracking-widest italic">Staff Member</th>
                            <th class="px-10 py-5 text-[10px] font-black text-slate-500 uppercase tracking-widest text-right italic">Gross Salary</th>
                            <th class="px-10 py-5 text-[10px] font-black text-red-500 uppercase tracking-widest text-right italic">Deductions</th>
                            <th class="px-10 py-5 text-[10px] font-black text-indigo-600 uppercase tracking-widest text-right italic">Net Paid</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                        <tr v-for="emp in filteredEmployees" :key="emp.id" class="hover:bg-slate-50/50 transition-colors">
                            <td class="px-10 py-5">
                                <p class="font-black text-slate-800 uppercase text-xs tracking-tight">{{ emp.name }}</p>
                                <p class="text-[9px] text-slate-400 font-bold font-mono uppercase tracking-tighter">{{ emp.employee_id }}</p>
                            </td>
                            <td class="px-10 py-5 text-right font-bold text-slate-500 text-xs italic">৳{{ emp.base_salary.toLocaleString() }}</td>
                            <td class="px-10 py-5 text-right font-bold text-red-400 text-xs">
                                <span v-if="emp.advance > 0">- ৳{{ emp.advance.toLocaleString() }}</span>
                                <span v-else class="text-slate-100">—</span>
                            </td>
                            <td class="px-10 py-5 text-right">
                                <span class="font-black text-slate-900 text-sm italic tracking-tighter">৳{{ emp.net_payable.toLocaleString() }}</span>
                            </td>
                        </tr>

                        <tr v-if="filteredEmployees.length === 0">
                            <td colspan="4" class="py-20 text-center">
                                <p class="text-slate-300 font-black uppercase text-[10px] tracking-[0.5em]">No records match "{{ searchQuery }}"</p>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="bg-slate-900 rounded-b-[32px] p-10 flex justify-between items-center text-white print:rounded-none">
                <div class="print:hidden">
                    <p class="text-[9px] font-bold text-slate-500 uppercase tracking-widest italic mb-1">Status: Archived</p>
                    <p class="text-[9px] font-bold text-slate-500 uppercase tracking-widest italic">Viewing {{ filteredEmployees.length }} of {{ monthData.employees.length }} records</p>
                </div>
                <div class="text-right w-full md:w-auto">
                    <p class="text-[10px] font-bold text-indigo-400 uppercase tracking-[0.4em] mb-2 italic">Total Monthly Payout</p>
                    <p class="text-4xl font-black italic tracking-tighter">৳{{ grandTotal.toLocaleString() }}</p>
                </div>
            </div>

            <div class="hidden print:flex justify-between mt-20 px-10 pb-10">
                <div class="w-56 border-t border-slate-900 pt-3 text-center text-[10px] font-black uppercase tracking-widest italic">Authorized By</div>
                <div class="w-56 border-t border-slate-900 pt-3 text-center text-[10px] font-black uppercase tracking-widest italic">Receiver Signature</div>
            </div>
        </div>
    </div>
</template>
