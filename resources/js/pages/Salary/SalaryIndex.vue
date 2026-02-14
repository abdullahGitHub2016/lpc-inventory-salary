<script setup>
import { ref, watch, computed, reactive } from 'vue';
import { useForm, router, Head, Link } from '@inertiajs/vue3';
import Pagination from '@/Components/Pagination.vue';
import debounce from 'lodash/debounce';

const props = defineProps({
    employees: { type: Object, default: () => ({ data: [] }) },
    advanceReasons: { type: Array, default: () => [] },
    filters: { type: Object, default: () => ({ search: '' }) }
});

// --- STATE MANAGEMENT ---
const lastEditedId = ref(null);
const searchQuery = ref(props.filters.search || '');
const showEmployeeModal = ref(false);
const isEditing = ref(false);
const showAdvanceModal = ref(false);
const showDetailsModal = ref(false);
const selectedEmp = ref(null);
const modalSearchId = ref('');

// Unified Form Object - renamed to 'form' to match your template requirements
const form = reactive({
    id: null,
    employee_id: '',
    name: '',
    base_salary: '',
    designation: '' // Included to prevent previous SQL errors
});

const advanceForm = useForm({
    employee_id: '',
    reason_id: '',
    amount: '',
    advance_date: new Date().toISOString().split('T')[0]
});

// --- SEARCH LOGIC ---
watch(searchQuery, debounce((value) => {
    router.get(route('salary.index'), { search: value }, {
        preserveState: true,
        replace: true,
        preserveScroll: true
    });
}, 300));

// --- COMPUTED PROPERTIES ---
const sortedEmployees = computed(() => {
    const dataArray = props.employees.data || [];

    // If you want the database order (latest first),
    // simply return the array as is.
    return dataArray;
});

const foundEmployee = computed(() => {
    if (!modalSearchId.value) return null;
    return props.employees.data.find(emp =>
        emp.employee_id.trim().toUpperCase() === modalSearchId.value.trim().toUpperCase()
    );
});

const liveNetPayable = computed(() => {
    if (!foundEmployee.value) return 0;
    const base = parseFloat(foundEmployee.value.base_salary || 0);
    const existingAdvance = parseFloat(foundEmployee.value.advance || 0);
    const newAmount = parseFloat(advanceForm.amount || 0);
    return base - existingAdvance - newAmount;
});

const showInvalidError = computed(() => modalSearchId.value.length >= 3 && !foundEmployee.value);

watch(foundEmployee, (newVal) => {
    advanceForm.employee_id = newVal ? newVal.id : '';
});

// --- MODAL ACTIONS ---
const openCreateModal = () => {
    isEditing.value = false;
    Object.assign(form, { id: null, employee_id: '', name: '', base_salary: '', designation: '' });
    showEmployeeModal.value = true;
};

const openEditModal = (emp) => {
    console.log("Editing employee:", emp); // Debugging line to check the employee object
    isEditing.value = true;
    Object.assign(form, {
        id: emp.id,
        employee_id: emp.employee_id,
        name: emp.name,
        // Map designation correctly
        designation: emp.designation || '',
        // Map the DB 'total_salary' back to the form 'base_salary'
        base_salary: emp.total_salary || emp.base_salary,
    });
    showEmployeeModal.value = true;
};

const submitEmployeeForm = () => {
    // Debugging: check your console (F12) to see if designation is here before sending
    console.log("Sending data:", form);

    if (isEditing.value) {
        router.put(route('employees.update', form.id), {
            employee_id: form.employee_id,
            name: form.name,
            designation: form.designation, // Ensure this is here
            base_salary: form.base_salary,
        }, {
            onSuccess: () => showEmployeeModal.value = false
        });
    } else {
        router.post(route('employees.store'), form, {
            onSuccess: () => showEmployeeModal.value = false
        });
    }
};

const deleteEmployee = (id) => {
    if (confirm("Are you sure you want to delete this employee?")) {
        router.delete(route('employees.destroy', id), {
            onSuccess: () => {
                // Optional: success message
            }
        });
    }
};

const submitAdvance = () => {
    advanceForm.post(route('salary.advance.store'), {
        onSuccess: () => {
            lastEditedId.value = advanceForm.employee_id;
            showAdvanceModal.value = false;
            advanceForm.reset();
            modalSearchId.value = '';
        }
    });
};

const openDetails = (emp) => {
    selectedEmp.value = emp;
    showDetailsModal.value = true;
};

// --- UTILS ---
const formatDate = (d) => new Date(d).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
const printLedger = () => window.print();
const currentMonthName = new Date().toLocaleDateString('en-GB', { month: 'long', year: 'numeric' });

const confirmMonthlyProcess = () => {
    if (confirm("Are you sure? This will freeze data and reset advances.")) {
        router.post(route('salary.process'));
    }
};
</script>

<template>

    <Head title="Payroll Master" />
    <div class="min-h-screen bg-gray-100 p-6 font-sans text-slate-900 print:bg-white print:p-0">
        <div class="max-w-6xl mx-auto">

            <div class="flex items-end justify-between mb-8 print:hidden">
                <div class="flex items-center gap-6">
                    <div>
                        <h1 class="text-3xl font-black tracking-tight text-slate-900 uppercase italic">
                            Payroll <span class="text-indigo-600">Ledger</span>
                        </h1>
                        <p class="text-[10px] font-bold text-slate-400 uppercase tracking-[0.3em] mt-1">
                            Active Month: {{ currentMonthName }}
                        </p>
                    </div>
                    <Link :href="route('salary.archive.index')"
                        class="flex items-center gap-2 bg-white border border-slate-200 px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 transition-all shadow-sm">
                        <span class="text-lg">📂</span>
                        <p class="text-[10px] font-black uppercase italic">Archives</p>
                    </Link>
                </div>

                <div class="flex items-center gap-3">
                    <input v-model="searchQuery" type="text" placeholder="Search Name/ID..."
                        class="bg-white border border-slate-200 rounded-xl px-4 py-3 text-xs font-bold outline-none focus:ring-2 focus:ring-indigo-500 w-64 shadow-sm" />

                    <button @click="printLedger"
                        class="bg-slate-800 text-white px-5 py-3 rounded-xl font-bold text-[10px] uppercase tracking-widest hover:bg-slate-700 transition-colors">
                        Print 🖨️
                    </button>
                    <button @click="openCreateModal"
                        class="bg-indigo-600 text-white px-6 py-3 rounded-2xl font-black uppercase italic text-[10px] tracking-widest hover:bg-slate-900 transition-all shadow-xl active:scale-95">
                        + New Employee
                    </button>
                    <button @click="confirmMonthlyProcess"
                        class="bg-white border-2 border-emerald-500 text-emerald-600 px-6 py-3 rounded-xl font-bold text-[10px] uppercase tracking-widest hover:bg-emerald-50 transition-colors">
                        Close Month
                    </button>
                    <button @click="showAdvanceModal = true"
                        class="bg-indigo-600 text-white px-6 py-3 rounded-xl font-bold text-[10px] uppercase tracking-widest shadow-lg shadow-indigo-200 hover:bg-indigo-700 transition-all">
                        + New Advance
                    </button>
                </div>
            </div>

            <div
                class="bg-white rounded-[32px] shadow-sm border border-slate-200 overflow-hidden print:border-none print:shadow-none">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-200">
                            <th class="px-6 py-4 font-bold text-slate-500 uppercase text-[10px] text-left italic">Staff
                                Info</th>
                            <th class="px-6 py-4 font-bold text-slate-500 uppercase text-[10px] text-right italic">Base
                                Salary</th>
                            <th class="px-6 py-4 font-bold text-red-500 uppercase text-[10px] text-right italic">Pending
                                Advance</th>
                            <th class="px-6 py-4 font-bold text-indigo-600 uppercase text-[10px] text-right italic">Net
                                Payable</th>
                            <th
                                class="px-6 py-4 font-bold text-slate-500 uppercase text-[10px] text-center italic print:hidden">
                                Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr v-for="emp in sortedEmployees" :key="emp.id"
                            :class="[emp.id === lastEditedId ? 'bg-indigo-50/50 border-l-4 border-l-indigo-500' : 'hover:bg-slate-50/50']">
                            <td class="px-6 py-4">
                                <div class="font-bold text-slate-800 uppercase text-xs">{{ emp.name }}</div>
                                <div class="text-[10px] text-slate-400 font-bold font-mono">
                                    {{ emp.designation }} • {{ emp.employee_id }}
                                </div>
                            </td>
                            <td class="px-6 py-4 text-right font-medium text-slate-500 italic">
                                ৳{{ emp.base_salary.toLocaleString() }}
                            </td>
                            <td class="px-6 py-4 text-right">
                                <span v-if="emp.advance > 0" class="text-red-500 font-bold italic">
                                    ৳{{ emp.advance.toLocaleString() }}
                                </span>
                                <span v-else class="text-slate-200 italic">৳0</span>
                            </td>
                            <td class="px-6 py-4 text-right">
                                <span
                                    class="bg-indigo-50 text-indigo-700 px-4 py-2 rounded-xl font-black border border-indigo-100 italic">
                                    ৳{{ emp.net_payable.toLocaleString() }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-center print:hidden">
                                <div class="flex items-center justify-center gap-4">
                                    <button @click="openDetails(emp)"
                                        class="text-lg hover:scale-125 transition-transform" title="History">📄</button>
                                    <button @click="openEditModal(emp)" class="hover:scale-125 transition-transform">
                                        ✏️
                                    </button>
                                    <button @click="deleteEmployee(emp.id)" class="text-red-400 hover:text-red-600" title="Delete">
        🗑️
    </button>
                                </div>
                            </td>
                        </tr>
                        <tr v-if="sortedEmployees.length === 0">
                            <td colspan="5"
                                class="py-20 text-center text-slate-300 font-black uppercase text-[10px] tracking-[0.4em]">
                                No matching records
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="mt-8 flex justify-center print:hidden">
                <Pagination :links="employees.links" />
            </div>
        </div>

        <div v-if="showAdvanceModal"
            class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
            <div
                class="bg-white rounded-[40px] w-full max-w-lg shadow-2xl overflow-hidden animate-in zoom-in duration-300">
                <div class="p-10">
                    <div class="flex justify-between items-start mb-8">
                        <div>
                            <h2 class="text-2xl font-black uppercase italic tracking-tighter text-slate-900">New <span
                                    class="text-indigo-600">Advance</span></h2>
                            <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1 italic">
                                Payroll Live Adjustment</p>
                        </div>
                        <button @click="showAdvanceModal = false"
                            class="text-slate-300 hover:text-red-500 text-2xl">×</button>
                    </div>

                    <div class="space-y-6">
                        <div>
                            <label
                                class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 italic">Employee
                                Search ID</label>
                            <input v-model="modalSearchId" type="text" placeholder="e.g. EMP-001"
                                class="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-5 py-4 text-sm font-bold focus:border-indigo-500 outline-none transition-all uppercase" />
                        </div>

                        <div v-if="foundEmployee"
                            class="bg-indigo-50 rounded-3xl p-6 border border-indigo-100 animate-in slide-in-from-top-4 duration-500">
                            <div class="flex justify-between items-center mb-4 pb-4 border-b border-indigo-100/50">
                                <div>
                                    <p class="text-[9px] font-black text-indigo-400 uppercase italic">Employee</p>
                                    <h3 class="text-lg font-black text-indigo-900 uppercase italic">{{
                                        foundEmployee.name }}</h3>
                                </div>
                                <div class="text-right">
                                    <p class="text-[9px] font-black text-indigo-400 uppercase italic">Current Net</p>
                                    <p class="text-sm font-bold text-indigo-900">৳{{
                                        foundEmployee.net_payable.toLocaleString() }}</p>
                                </div>
                            </div>
                            <div class="flex justify-between items-center">
                                <p class="text-[10px] font-black text-indigo-400 uppercase italic">Forecast Net Payable:
                                </p>
                                <p class="text-xl font-black italic"
                                    :class="liveNetPayable < 0 ? 'text-red-500' : 'text-indigo-600'">
                                    ৳{{ liveNetPayable.toLocaleString() }}
                                </p>
                            </div>
                        </div>

                        <div v-if="foundEmployee" class="grid grid-cols-2 gap-4">
                            <div>
                                <label
                                    class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 italic">Reason</label>
                                <select v-model="advanceForm.reason_id"
                                    class="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-5 py-4 text-sm font-bold outline-none focus:border-indigo-500">
                                    <option value="">Select Reason</option>
                                    <option v-for="r in advanceReasons" :key="r.id" :value="r.id">{{ r.reason_name }}
                                    </option>
                                </select>
                            </div>
                            <div>
                                <label
                                    class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 italic">Amount
                                    (৳)</label>
                                <input v-model="advanceForm.amount" type="number"
                                    class="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-5 py-4 text-sm font-bold outline-none focus:border-indigo-500" />
                            </div>
                        </div>

                        <div v-if="showInvalidError"
                            class="text-center p-6 bg-red-50 rounded-2xl border border-red-100">
                            <p class="text-[10px] font-black text-red-500 uppercase italic">No Record Found for ID: {{
                                modalSearchId }}</p>
                        </div>
                    </div>
                </div>

                <div class="p-4 bg-slate-50 flex justify-end gap-3 px-10 border-t border-slate-100">
                    <button @click="showAdvanceModal = false"
                        class="text-[10px] font-bold text-slate-400 px-4 uppercase tracking-widest">Cancel</button>
                    <button @click="submitAdvance" :disabled="!foundEmployee || !advanceForm.amount"
                        class="bg-indigo-600 text-white px-10 py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest shadow-lg shadow-indigo-200 disabled:opacity-30">
                        Confirm Advance
                    </button>
                </div>
            </div>
        </div>

        <div v-if="showEmployeeModal"
            class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
            <div
                class="bg-white w-full max-w-md rounded-[40px] shadow-2xl overflow-hidden animate-in zoom-in duration-200">
                <div class="p-10">
                    <div class="flex justify-between items-center mb-8">
                        <h2 class="text-xl font-black uppercase italic tracking-tighter">
                            {{ isEditing ? 'Edit' : 'New' }} <span class="text-indigo-600">Employee</span>
                        </h2>
                        <button @click="showEmployeeModal = false"
                            class="text-slate-300 hover:text-red-500 text-2xl">&times;</button>
                    </div>

                    <div class="space-y-5">
                        <div>
                            <label
                                class="text-[9px] font-black uppercase text-slate-400 mb-1 block tracking-widest">Employee
                                ID</label>
                            <input v-model="form.employee_id" type="text" placeholder="e.g. LPC-001"
                                class="w-full bg-slate-50 border-none rounded-xl px-5 py-3 text-sm font-bold focus:ring-2 focus:ring-indigo-500 uppercase" />
                        </div>
                        <div>
                            <label
                                class="text-[9px] font-black uppercase text-slate-400 mb-1 block tracking-widest">Full
                                Name</label>
                            <input v-model="form.name" type="text" placeholder="John Doe"
                                class="w-full bg-slate-50 border-none rounded-xl px-5 py-3 text-sm font-bold focus:ring-2 focus:ring-indigo-500" />
                        </div>
                        <div>
                            <label
                                class="text-[9px] font-black uppercase text-slate-400 mb-1 block tracking-widest">Designation</label>
                            <input v-model="form.designation" type="text" placeholder="e.g. Engineer"
                                class="w-full bg-slate-50 border-none rounded-xl px-5 py-3 text-sm font-bold focus:ring-2 focus:ring-indigo-500" />
                        </div>
                        <div>
                            <label
                                class="text-[9px] font-black uppercase text-slate-400 mb-1 block tracking-widest">Base
                                Salary</label>
                            <input v-model="form.base_salary" type="number" placeholder="0.00"
                                class="w-full bg-slate-50 border-none rounded-xl px-5 py-3 text-sm font-bold focus:ring-2 focus:ring-indigo-500" />
                        </div>
                    </div>

                    <div class="flex gap-4 mt-10">
                        <button @click="showEmployeeModal = false"
                            class="flex-1 py-4 text-[10px] font-black uppercase text-slate-400">Cancel</button>
                        <button @click="submitEmployeeForm"
                            class="flex-[2] bg-slate-900 text-white py-4 rounded-2xl font-black uppercase italic text-[10px] tracking-widest hover:bg-indigo-600 transition-all shadow-lg">
                            {{ isEditing ? 'Update Records' : 'Register Entry' }}
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div v-if="showDetailsModal"
            class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
            <div
                class="bg-white rounded-[24px] w-full max-w-2xl shadow-2xl overflow-hidden animate-in zoom-in duration-300">
                <div class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                    <div>
                        <h2 class="text-xl font-black text-slate-900 uppercase italic tracking-tighter">
                            {{ selectedEmp?.name }} <span class="text-indigo-600">Ledger</span>
                        </h2>
                        <p class="text-[9px] font-bold text-slate-400 uppercase tracking-widest font-mono">ID: {{
                            selectedEmp?.employee_id }}</p>
                    </div>
                    <button @click="showDetailsModal = false"
                        class="text-slate-300 hover:text-red-500 text-2xl">×</button>
                </div>
                <div class="max-h-[450px] overflow-y-auto custom-scrollbar">
                    <table class="w-full text-left border-collapse text-xs">
                        <thead class="sticky top-0 bg-slate-100 z-10">
                            <tr
                                class="text-[9px] font-black text-slate-500 uppercase tracking-widest italic border-b border-slate-200">
                                <th class="px-4 py-3 border-r border-slate-200">#</th>
                                <th class="px-4 py-3 border-r border-slate-200">Date</th>
                                <th class="px-4 py-3 border-r border-slate-200">Reason</th>
                                <th class="px-4 py-3 text-right">Amount (৳)</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-200">
                            <tr v-for="(adv, index) in selectedEmp?.advance_history" :key="adv.id"
                                class="hover:bg-indigo-50/30 font-bold">
                                <td class="px-4 py-2 border-r border-slate-100 text-slate-400">{{ index + 1 }}</td>
                                <td class="px-4 py-2 border-r border-slate-100">{{ formatDate(adv.advance_date) }}</td>
                                <td class="px-4 py-2 border-r border-slate-100 italic uppercase">{{
                                    adv.reason?.reason_name || 'General' }}</td>
                                <td class="px-4 py-2 text-right text-red-600">- {{ adv.amount.toLocaleString() }}</td>
                            </tr>
                            <tr v-if="!selectedEmp?.advance_history?.length">
                                <td colspan="4" class="py-20 text-center text-slate-300 uppercase font-black">No
                                    transactions recorded</td>
                            </tr>
                        </tbody>
                        <tfoot class="sticky bottom-0 bg-white border-t-2 border-slate-200 shadow-sm">
                            <tr class="text-slate-900">
                                <td colspan="3"
                                    class="px-4 py-4 text-right text-[10px] font-black uppercase italic tracking-widest">
                                    Total Pending Advance</td>
                                <td class="px-4 py-4 text-right text-lg font-black text-red-600 italic">৳{{
                                    selectedEmp?.advance.toLocaleString() }}</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <div class="p-4 bg-slate-50 flex justify-end px-10 border-t border-slate-100">
                    <button @click="showDetailsModal = false"
                        class="bg-slate-900 text-white px-10 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest">Close
                        Ledger</button>
                </div>
            </div>
        </div>

    </div>
</template>

<style>
@media print {
    .print\:hidden {
        display: none !important;
    }

    body {
        background-color: white !important;
    }

    .max-w-6xl {
        max-width: 100% !important;
        margin: 0 !important;
    }
}

.custom-scrollbar::-webkit-scrollbar {
    width: 4px;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
    background: #e2e8f0;
    border-radius: 10px;
}
</style>
