<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { ref } from 'vue';
import { useForm, router } from '@inertiajs/vue3';

const props = defineProps({ sites: Array });

const showModal = ref(false);
const editMode = ref(false);

const siteForm = useForm({
    id: null,
    location_name: '',
    address: '', // Optional additional field
});

const openCreate = () => {
    editMode.value = false;
    siteForm.reset();
    showModal.value = true;
};

const openEdit = (site) => {
    editMode.value = true;
    siteForm.id = site.id;
    siteForm.location_name = site.location_name;
    showModal.value = true;
};

const submitSite = () => {
    if (editMode.value) {
        siteForm.put(route('sites.update', siteForm.id), {
            onSuccess: () => showModal.value = false
        });
    } else {
        siteForm.post(route('sites.store'), {
            onSuccess: () => showModal.value = false
        });
    }
};

const deleteSite = (id) => {
    if (confirm('Delete this site? Ensure no equipment is currently assigned here.')) {
        router.delete(route('sites.destroy', id));
    }
};
</script>

<template>
    <AuthenticatedLayout>
        <div class="p-8">
            <div class="flex justify-between mb-6">
                <h1 class="text-2xl font-black uppercase italic">Project Sites</h1>
                <button @click="openCreate" class="bg-emerald-600 text-white px-4 py-2 rounded-xl text-[10px] font-black uppercase">
                    + Add Site
                </button>
            </div>

            <div class="bg-white rounded-3xl border border-gray-200 overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-gray-50 border-b text-[10px] font-black uppercase text-gray-400">
                        <tr>
                            <th class="px-6 py-4">Location Name</th>
                            <th class="px-6 py-4 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr v-for="site in sites" :key="site.id">
                            <td class="px-6 py-4 font-bold">{{ site.location_name }}</td>
                            <td class="px-6 py-4 text-right">
                                <button @click="openEdit(site)" class="text-indigo-600 font-black text-[10px] uppercase underline mx-2">Edit</button>
                                <button @click="deleteSite(site.id)" class="text-red-500 font-black text-[10px] uppercase underline mx-2">Delete</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div v-if="showModal" class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 backdrop-blur-sm">
            <div class="bg-white rounded-[2rem] p-8 w-full max-w-md">
                <h3 class="text-xl font-black uppercase italic mb-6">{{ editMode ? 'Edit Site' : 'New Site' }}</h3>
                <form @submit.prevent="submitSite">
                    <label class="text-[10px] font-black uppercase text-gray-400 ml-2">Location Name</label>
                    <input v-model="siteForm.location_name" type="text" class="w-full border-gray-200 rounded-2xl bg-gray-50 mb-4" required />

                    <div class="flex gap-3">
                        <button type="button" @click="showModal = false" class="flex-1 py-4 bg-gray-100 rounded-2xl font-black uppercase text-[10px]">Cancel</button>
                        <button type="submit" class="flex-1 py-4 bg-indigo-600 text-white rounded-2xl font-black uppercase text-[10px]">Save Site</button>
                    </div>
                </form>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
