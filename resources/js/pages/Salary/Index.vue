<script setup>
import { ref, watch, computed } from 'vue';
import { useForm, router, Head } from '@inertiajs/vue3';

const props = defineProps({
    employees: { type: Array, default: () => [] },
    advanceReasons: { type: Array, default: () => [] },
});

// A local ref to keep track of the last employee we edited
const lastEditedId = ref(null);

// FORCED SORTING:
// 1. If an ID matches 'lastEditedId', it goes to the top (return -1)
// 2. Otherwise, sort by ID descending (newest entries first)
const sortedEmployees = computed(() => {
    return [...props.employees].sort((a, b) => {
        if (a.id === lastEditedId.value) return -1;
        if (b.id === lastEditedId.value) return 1;
        return b.id - a.id;
    });
});

const currentMonthName = new Date().toLocaleDateString('en-GB', { month: 'long', year: 'numeric' });

// --- MODAL: NEW ENTRY ---
const showAdvanceModal = ref(false);
const modalSearchId = ref('');
const advanceForm = useForm({
    employee_id: '',
    reason_id: '',
    amount: '',
    advance_date: new Date().toISOString().split('T')[0]
});

const foundEmployee = computed(() => {
    if (!modalSearchId.value) return null;
    return props.employees.find(emp =>
        emp.employee_id.trim().toUpperCase() === modalSearchId.value.trim().toUpperCase()
    );
});

const showInvalidError = computed(() => modalSearchId.value.length >= 3 && !foundEmployee.value);

watch(foundEmployee, (newVal) => { advanceForm.employee_id = newVal ? newVal.id : ''; });

const liveNetPayable = computed(() => {
    if (!foundEmployee.value) return 0;
    return parseFloat(foundEmployee.value.base_salary || 0) - parseFloat(foundEmployee.value.advance || 0) - (parseFloat(advanceForm.amount) || 0);
});

const submitAdvance = () => {
    advanceForm.post(route('salary.advance.store'), {
        onSuccess: () => {
            // CAPTURE THE ID BEFORE RESETTING
            lastEditedId.value = advanceForm.employee_id;

            showAdvanceModal.value = false;
            advanceForm.reset();
            modalSearchId.value = '';
        }
    });
};

// --- MODAL: HISTORY LEDGER ---
const showDetailsModal = ref(false);
const selectedEmp = ref(null);

const sortedHistory = computed(() => {
    if (!selectedEmp.value?.advance_history) return [];
    return [...selectedEmp.value.advance_history].sort((a, b) => b.id - a.id);
});

const openDetails = (emp) => { selectedEmp.value = emp; showDetailsModal.value = true; };
const formatDate = (d) => new Date(d).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
</script>

<template>
    <Head title="Payroll Master" />

    <div class="min-h-screen bg-gray-100 p-6 font-sans text-slate-900">
        <div class="max-w-6xl mx-auto">

            <div class="flex items-end justify-between mb-8">
                <div>
                    <h1 class="text-3xl font-bold tracking-tight text-slate-900">Payroll <span class="text-indigo-600 italic">Ledger</span></h1>
                    <p class="text-xs font-semibold text-slate-500 uppercase tracking-widest mt-1 italic">Period: {{ currentMonthName }}</p>
                </div>
                <button @click="showAdvanceModal = true" class="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-3 rounded-xl font-bold text-sm shadow-lg active:scale-95 transition-all">
                    + New Advance
                </button>
            </div>

            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-200">
                            <th class="px-6 py-4 font-bold text-slate-500 uppercase text-[10px] tracking-wider text-left italic">Staff Info</th>
                            <th class="px-6 py-4 font-bold text-slate-500 uppercase text-[10px] tracking-wider text-right italic">Salary</th>
                            <th class="px-6 py-4 font-bold text-red-500 uppercase text-[10px] tracking-wider text-right italic">Monthly Advance</th>
                            <th class="px-6 py-4 font-bold text-indigo-600 uppercase text-[10px] tracking-wider text-right italic">Net Payable</th>
                            <th class="px-6 py-4 font-bold text-slate-500 uppercase text-[10px] tracking-wider text-center italic">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr v-for="emp in sortedEmployees" :key="emp.id"
                            :class="[emp.id === lastEditedId ? 'bg-indigo-50/50 border-l-4 border-l-indigo-500' : 'hover:bg-slate-50/80']"
                            class="transition-all duration-500">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-2">
                                    <div v-if="emp.id === lastEditedId" class="h-2 w-2 bg-indigo-500 rounded-full animate-ping"></div>
                                    <div class="font-bold text-slate-800 uppercase">{{ emp.name }}</div>
                                </div>
                                <div class="text-[10px] text-slate-400 font-bold tracking-widest">{{ emp.employee_id }}</div>
                            </td>
                            <td class="px-6 py-4 text-right font-medium text-slate-500">৳{{ emp.base_salary.toLocaleString() }}</td>
                            <td class="px-6 py-4 text-right">
                                <span v-if="emp.advance > 0" class="text-red-500 font-bold">৳{{ emp.advance.toLocaleString() }}</span>
                                <span v-else class="text-slate-200">৳0.00</span>
                            </td>
                            <td class="px-6 py-4 text-right">
                                <span class="bg-indigo-50 text-indigo-700 px-3 py-1.5 rounded-lg font-bold border border-indigo-100 italic">
                                    ৳{{ emp.net_payable.toLocaleString() }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-center">
                                <button @click="openDetails(emp)" class="text-slate-300 hover:text-indigo-600 transition-colors">
                                    <span class="text-xl">📄</span>
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div v-if="showAdvanceModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
            <div class="bg-white w-full max-w-md rounded-2xl shadow-2xl overflow-hidden animate-in zoom-in duration-200">
                <div class="p-6 border-b border-slate-100 flex justify-between items-center">
                    <h2 class="font-bold text-slate-800 uppercase text-sm tracking-widest italic">Verify & Add</h2>
                    <button @click="showAdvanceModal = false" class="text-slate-400 hover:text-slate-600 font-bold">✕</button>
                </div>

                <form @submit.prevent="submitAdvance" class="p-6 space-y-6">
                    <div>
                        <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2 ml-1 tracking-widest">Input Employee ID</label>
                        <input v-model="modalSearchId" type="text" placeholder="Full ID Only" class="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-sm font-bold focus:ring-2 focus:ring-indigo-500 outline-none uppercase tracking-widest" autocomplete="off" />
                        <p v-if="showInvalidError" class="text-red-500 text-[10px] font-bold mt-2 ml-1 italic animate-pulse">⚠️ GIVE VALID EMP ID</p>
                    </div>

                    <div v-if="foundEmployee" class="bg-slate-900 rounded-xl p-5 border-l-4 border-indigo-500 shadow-xl">
                        <p class="text-[9px] font-bold text-indigo-400 uppercase tracking-widest mb-1 italic">Matched Profile</p>
                        <div class="flex justify-between items-end">
                            <span class="font-black text-white uppercase text-sm">{{ foundEmployee.name }}</span>
                            <div class="text-right">
                                <p class="text-[9px] font-bold text-slate-500 uppercase italic">Current Balance</p>
                                <p class="text-xl font-black text-indigo-400 italic">৳{{ liveNetPayable.toLocaleString() }}</p>
                            </div>
                        </div>
                    </div>

                    <div :class="{'opacity-20 pointer-events-none blur-[1px]': !foundEmployee}" class="space-y-4 transition-all">
                        <select v-model="advanceForm.reason_id" class="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-sm font-bold italic">
                            <option value="" disabled>Select Reason...</option>
                            <option v-for="r in advanceReasons" :key="r.id" :value="r.id">{{ r.reason_name }}</option>
                        </select>
                        <div class="grid grid-cols-2 gap-4">
                            <input v-model="advanceForm.amount" type="number" placeholder="Amount" class="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-sm font-bold" />
                            <input v-model="advanceForm.advance_date" type="date" class="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-sm font-bold" />
                        </div>
                    </div>

                    <button type="submit" :disabled="!foundEmployee || liveNetPayable < 0" class="w-full bg-indigo-600 text-white py-4 rounded-xl font-bold text-xs uppercase tracking-widest shadow-lg hover:bg-indigo-700 disabled:bg-slate-100 disabled:text-slate-300 transition-all">
                        Confirm Transaction
                    </button>
                </form>
            </div>
        </div>

        <div v-if="showDetailsModal && selectedEmp" class="fixed inset-0 bg-slate-900/70 backdrop-blur-md z-50 flex items-center justify-center p-6">
            <div class="bg-white w-full max-w-4xl h-[85vh] rounded-2xl shadow-2xl flex flex-col overflow-hidden">
                <div class="p-6 border-b border-slate-100 flex justify-between items-center px-8">
                    <h3 class="font-bold text-slate-800 uppercase text-xs tracking-[0.2em] italic">Current Monthly Statement</h3>
                    <button @click="showDetailsModal = false" class="text-slate-300 hover:text-slate-900 transition-colors font-bold">✕</button>
                </div>
                <div class="flex-1 flex overflow-hidden">
                    <div class="w-1/3 bg-slate-50 p-8 border-r border-slate-100">
                        <div class="mb-10">
                            <p class="text-[9px] font-bold text-slate-400 uppercase tracking-widest mb-2 italic">Employee Name</p>
                            <h4 class="text-2xl font-black text-slate-900 leading-none uppercase">{{ selectedEmp.name }}</h4>
                            <p class="text-indigo-600 font-bold text-[10px] mt-2 tracking-[0.3em]">{{ selectedEmp.employee_id }}</p>
                        </div>
                        <div class="mt-auto space-y-3">
                            <div class="bg-white p-5 rounded-xl border border-slate-100 shadow-sm space-y-4">
                                <div class="flex justify-between items-center"><span class="text-[9px] font-bold text-slate-400 uppercase italic">Base</span><span class="text-sm font-bold">৳{{ selectedEmp.base_salary.toLocaleString() }}</span></div>
                                <div class="flex justify-between items-center border-t border-slate-50 pt-3"><span class="text-[9px] font-bold text-red-400 uppercase italic">Deducted</span><span class="text-sm font-bold text-red-500">-৳{{ selectedEmp.advance.toLocaleString() }}</span></div>
                            </div>
                            <div class="bg-slate-900 p-6 rounded-xl text-white">
                                <p class="text-[9px] font-bold text-slate-500 uppercase mb-1 tracking-widest italic">Net Monthly Payable</p>
                                <p class="text-3xl font-black text-indigo-400 italic">৳{{ selectedEmp.net_payable.toLocaleString() }}</p>
                            </div>
                        </div>
                    </div>
                    <div class="flex-1 bg-white overflow-y-auto p-8 custom-scrollbar">
                         <div v-for="adv in sortedHistory" :key="adv.id" class="flex justify-between items-center p-4 bg-slate-50/50 rounded-xl border border-slate-100 mb-3">
                            <div class="flex items-center gap-4">
                                <div>
                                    <p class="text-xs font-bold text-slate-800 uppercase italic">{{ adv.reason?.reason_name || 'Advance' }}</p>
                                    <p class="text-[9px] text-slate-400 uppercase font-bold tracking-tighter">{{ formatDate(adv.advance_date) }}</p>
                                </div>
                            </div>
                            <div class="text-right font-black text-red-500 text-sm">- ৳{{ adv.amount.toLocaleString() }}</div>
                        </div>
                    </div>
                </div>
                <div class="p-4 border-t border-slate-50 bg-white flex justify-end gap-3 px-8">
                    <button @click="showDetailsModal = false" class="text-[10px] font-bold text-slate-400 px-4 uppercase tracking-widest">Close</button>
                    <button @click="window.print()" class="bg-slate-900 text-white px-8 py-3 rounded-xl text-[10px] font-bold uppercase tracking-widest">Print Record</button>
                </div>
            </div>
        </div>

    </div>
</template>
