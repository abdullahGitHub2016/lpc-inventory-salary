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
                    <Link :href="route('inventory.fleet')"
                        class="group bg-white p-8 rounded-[40px] shadow-sm border border-slate-200 hover:shadow-xl transition-all">
                        <h3 class="text-2xl font-black uppercase italic text-slate-900">Fleet Hub</h3>
                    </Link>
                    <!--
                    <Link :href="route('inventory.depo')"
                        class="group bg-white p-8 rounded-[40px] shadow-sm border border-slate-200 hover:shadow-xl transition-all">
                        <h3 class="text-2xl font-black uppercase italic text-slate-900">Depo Hub</h3>
                    </Link>
                    -->
                </div>


            </div>
        </div>

    </AuthenticatedLayout>
</template>
