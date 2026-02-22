<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { ref } from 'vue';
import { useForm, Head, router } from '@inertiajs/vue3';

const props = defineProps({ reasons: Array });

const showModal = ref(false);
const editMode = ref(false);

const form = useForm({
    id: null,
    reason_name: '',
});

const openCreate = () => {
    editMode.value = false;
    form.reset();
    showModal.value = true;
};

const openEdit = (reason) => {
    editMode.value = true;
    form.id = reason.id;
    form.reason_name = reason.reason_name;
    showModal.value = true;
};

const submit = () => {
    if (editMode.value) {
        form.put(route('advance-reasons.update', form.id), { onSuccess: () => showModal.value = false });
    } else {
        form.post(route('advance-reasons.store'), { onSuccess: () => showModal.value = false });
    }
};
</script>

<template>
    <Head title="Advance Reasons" />
    <AuthenticatedLayout>
        <template #header>
            <h2 class="font-black text-xl text-gray-800 uppercase italic">Configure Advance Reasons</h2>
        </template>

        <div class="py-12 px-4 max-w-5xl mx-auto">
            <div class="flex justify-end mb-6">
                <button @click="openCreate" class="bg-indigo-600 text-white px-6 py-3 rounded-2xl font-black text-[10px] uppercase shadow-lg shadow-indigo-100">
                    + Add New Reason
                </button>
            </div>

            <div class="bg-white rounded-[2.5rem] shadow-sm border border-slate-200 overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-slate-50 border-b border-slate-100">
                        <tr>
                            <th class="px-8 py-5 text-[10px] font-black text-slate-400 uppercase italic">Reason Description</th>
                            <th class="px-8 py-5 text-right text-[10px] font-black text-slate-400 uppercase italic">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr v-for="reason in reasons" :key="reason.id" class="hover:bg-slate-50/50">
                            <td class="px-8 py-6 font-black text-slate-800 text-sm uppercase">{{ reason.reason_name }}</td>
                            <td class="px-8 py-6 text-right">
                                <button @click="openEdit(reason)" class="text-indigo-600 font-black text-[10px] uppercase underline mx-2">Edit</button>
                                <button @click="router.delete(route('advance-reasons.destroy', reason.id))" class="text-red-500 font-black text-[10px] uppercase underline mx-2">Delete</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div v-if="showModal" class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 p-4 backdrop-blur-sm">
            <div class="bg-white rounded-[2.5rem] p-8 w-full max-w-md shadow-2xl">
                <h3 class="text-xl font-black uppercase italic mb-6 text-slate-900">{{ editMode ? 'Edit Reason' : 'New Reason' }}</h3>
                <form @submit.prevent="submit">
                    <label class="text-[10px] font-black uppercase text-slate-400 ml-2 mb-1 block">Reason Name</label>
                    <input v-model="form.reason_name" type="text" class="w-full border-none rounded-2xl bg-slate-50 p-4 text-sm font-bold mb-6" required />
                    <div class="flex gap-3">
                        <button type="button" @click="showModal = false" class="flex-1 py-4 bg-slate-100 rounded-2xl font-black uppercase text-[10px]">Cancel</button>
                        <button type="submit" class="flex-1 py-4 bg-indigo-600 text-white rounded-2xl font-black uppercase text-[10px] shadow-lg">Save Configuration</button>
                    </div>
                </form>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
