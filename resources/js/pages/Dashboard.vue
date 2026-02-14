<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link, useForm, router } from '@inertiajs/vue3';
import { ref } from 'vue';

const props = defineProps({
    advanceReasons: Array, // This contains the 4 rows from your MySQL table
    auth: Object
});

const showReasonModal = ref(false);

// Match your DB column 'reason_name'
const form = useForm({
    reason_name: '',
});

const submitReason = () => {
    form.post(route('settings.reasons.store'), {
        onSuccess: () => {
            form.reset();
            showReasonModal.value = false;
        },
    });
};

const deleteReason = (id) => {
    if (confirm('Permanently delete this reason?')) {
        router.delete(route('settings.reasons.destroy', id), {
            preserveScroll: true
        });
    }
};

const editingId = ref(null);
const editForm = useForm({
    reason_name: ''
});

// Start editing: fill the form and show input
const startEdit = (reason) => {
    editingId.value = reason.id;
    editForm.reason_name = reason.reason_name;
};

// Save the change
const saveEdit = (id) => {
    editForm.patch(route('settings.reasons.update', id), {
        onSuccess: () => editingId.value = null,
    });
};

const cancelEdit = () => {
    editingId.value = null;
    editForm.reset();
};
</script>

<template>

    <Head title="Dashboard" />
    <AuthenticatedLayout>
        <template #header>
            <h2 class="text-2xl font-black uppercase italic tracking-tighter text-slate-800">
                System <span class="text-indigo-600">Command Center</span>
            </h2>
        </template>

        <div class="py-12 bg-slate-50 min-h-screen">
            <div class="mx-auto max-w-7xl sm:px-6 lg:px-8 space-y-8">

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <Link :href="route('salary.index')"
                        class="group bg-white p-8 rounded-[40px] shadow-sm border border-slate-200 hover:shadow-xl transition-all">
                        <h3 class="text-2xl font-black uppercase italic text-slate-900">Salary Management</h3>
                    </Link>
                    <Link :href="route('inventory.index')"
                        class="group bg-white p-8 rounded-[40px] shadow-sm border border-slate-200 hover:shadow-xl transition-all">
                        <h3 class="text-2xl font-black uppercase italic text-slate-900">Inventory Hub</h3>
                    </Link>
                </div>

                <div class="bg-white rounded-[40px] p-10 shadow-sm border border-slate-200">
                    <div class="flex justify-between items-center mb-8">
                        <h2 class="text-xl font-black uppercase italic text-slate-900">Advance Configuration</h2>
                        <button @click="showReasonModal = true"
                            class="bg-slate-900 text-white px-6 py-3 rounded-2xl text-[10px] font-black uppercase italic hover:bg-indigo-600">
                            + Add Reason
                        </button>
                    </div>

                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                        <div v-for="reason in advanceReasons" :key="reason.id"
                            class="flex justify-between items-center bg-slate-50 px-6 py-4 rounded-2xl border border-slate-100 group">

                            <div v-if="editingId === reason.id" class="flex items-center gap-2 w-full">
                                <input v-model="editForm.reason_name" type="text"
                                    class="text-xs font-bold uppercase italic border-indigo-500 rounded-lg p-1 w-full" />
                                <button @click="saveEdit(reason.id)" class="text-green-500 text-lg">✅</button>
                                <button @click="cancelEdit" class="text-slate-400 text-lg">❌</button>
                            </div>

                            <div v-else class="flex justify-between items-center w-full">
                                <span class="text-xs font-bold text-slate-700 uppercase italic">{{ reason.reason_name
                                    }}</span>
                                <div class="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button @click="startEdit(reason)"
                                        class="text-indigo-400 hover:text-indigo-600">✏️</button>
                                    <button @click="deleteReason(reason.id)"
                                        class="text-slate-300 hover:text-red-500">🗑️</button>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div v-if="showReasonModal"
            class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
            <div class="bg-white rounded-[40px] p-10 w-full max-w-md shadow-2xl">
                <h3 class="text-xl font-black uppercase italic mb-6">New Reason</h3>
                <form @submit.prevent="submitReason" class="space-y-4">
                    <input v-model="form.reason_name" type="text" placeholder="Reason Name" required
                        class="w-full bg-slate-50 border-none rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-indigo-500" />
                    <div class="flex gap-3">
                        <button type="button" @click="showReasonModal = false"
                            class="flex-1 py-4 text-xs font-black uppercase italic text-slate-400">Cancel</button>
                        <button type="submit"
                            class="flex-1 bg-indigo-600 text-white rounded-2xl py-4 text-xs font-black uppercase italic"
                            :disabled="form.processing">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
