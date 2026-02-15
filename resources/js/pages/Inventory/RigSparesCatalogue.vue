<template>
    <div class="min-h-screen bg-slate-50 pb-20 px-6">

        <div class="max-w-7xl mx-auto pt-8 flex justify-between items-center">
            <div>
                <h1 class="text-3xl font-black text-slate-900 italic tracking-tighter uppercase">{{ rig.name }}</h1>
                <p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Rig Catalogue & Spares Management</p>
            </div>
            <div class="flex gap-4">
                <div class="bg-white px-6 py-3 rounded-2xl border border-slate-100 shadow-sm text-center">
                    <div class="text-[10px] font-black text-slate-400 uppercase">Current Site</div>
                    <div class="text-sm font-bold text-slate-700">{{ rig.site?.name || 'In Transit' }}</div>
                </div>
            </div>
        </div>

        <div class="max-w-7xl mx-auto mt-8">
            <div class="bg-white rounded-[2.5rem] p-8 shadow-sm border border-slate-100">
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h3 class="text-xs font-black uppercase text-slate-400 tracking-widest italic">Technical Library</h3>
                        <p class="text-[10px] text-slate-400 italic">Manuals, Schematics & Parts Books</p>
                    </div>

                    <input type="file" multiple class="hidden" ref="fileUpload" @change="handleFileUpload" />
                    <button @click="$refs.fileUpload.click()"
                            class="px-6 py-2 bg-indigo-50 text-indigo-600 rounded-full text-[10px] font-black uppercase hover:bg-indigo-100 transition">
                        + Upload Manual
                    </button>
                </div>

                <div v-if="rig.documents && rig.documents.length > 0" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div v-for="doc in rig.documents" :key="doc.id"
                         class="group flex items-center gap-4 p-4 bg-slate-50 rounded-2xl border border-transparent hover:border-indigo-200 hover:bg-white transition-all">
                        <div class="w-10 h-10 flex items-center justify-center rounded-xl bg-white shadow-sm text-lg">📕</div>
                        <div class="flex flex-col overflow-hidden">
                            <span class="text-xs font-bold text-slate-700 truncate w-32" :title="doc.file_name">{{ doc.file_name }}</span>
                            <div class="flex gap-3 mt-1">
                                <a :href="doc.file_path" target="_blank" class="text-[9px] font-black uppercase text-indigo-500 hover:underline">View</a>
                                <button @click="deleteDoc(doc.id)" class="text-[9px] font-black uppercase text-red-400 opacity-0 group-hover:opacity-100 transition">Delete</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div v-else class="text-center py-8 border-2 border-dashed border-slate-100 rounded-[2rem] text-slate-400 text-xs italic">
                    No technical documents uploaded for this rig.
                </div>
            </div>
        </div>

        <div class="max-w-7xl mx-auto mt-8">
            <form @submit.prevent="submitLink" class="bg-white rounded-[2.5rem] p-8 shadow-sm border border-slate-100 grid grid-cols-1 md:grid-cols-5 gap-6 items-end">
                <div>
                    <label class="text-[10px] font-black uppercase text-slate-400 ml-2 mb-1 block">Part Name</label>
                    <input v-model="linkForm.new_part_name" type="text" placeholder="e.g. Main Winch Motor"
                           class="w-full border-slate-200 rounded-2xl p-4 text-sm focus:ring-indigo-500 bg-slate-50" required />
                </div>
                <div>
                    <label class="text-[10px] font-black uppercase text-slate-400 ml-2 mb-1 block">Part Number</label>
                    <input v-model="linkForm.part_number" type="text" placeholder="47100XXX"
                           class="w-full border-slate-200 rounded-2xl p-4 text-sm focus:ring-indigo-500 bg-slate-50" required />
                </div>

                <div class="flex flex-col">
                    <div class="flex justify-between items-center mb-1 px-2">
                        <label class="text-[10px] font-black uppercase text-slate-400">Group</label>
                        <button type="button" @click="isNewGroup = !isNewGroup" class="text-[9px] font-black uppercase text-indigo-500 hover:underline">
                            {{ isNewGroup ? 'Select Existing' : '+ New Group' }}
                        </button>
                    </div>
                    <select v-if="!isNewGroup" v-model="linkForm.functional_group" class="w-full border-slate-200 rounded-2xl p-4 text-sm bg-slate-50" required>
                        <option value="" disabled>Select Group...</option>
                        <option v-for="group in existingGroups" :key="group" :value="group">{{ group }}</option>
                    </select>
                    <input v-else v-model="linkForm.functional_group" type="text" placeholder="e.g. Hydraulics" class="w-full border-indigo-200 rounded-2xl p-4 text-sm" required />
                </div>

                <div>
                    <label class="text-[10px] font-black uppercase text-slate-400 ml-2 mb-1 block">Total Qty</label>
                    <input v-model="linkForm.quantity_to_add" type="number" min="1" placeholder="1" class="w-full border-slate-200 rounded-2xl p-4 text-sm bg-slate-50" required />
                </div>

                <button type="submit" class="h-[54px] bg-slate-900 text-white rounded-2xl font-black uppercase text-xs hover:bg-indigo-600 transition shadow-lg">
                    Add to Catalogue
                </button>
            </form>
        </div>

        <div class="max-w-7xl mx-auto mt-8">
            <div v-for="(parts, group) in sparesGrouped" :key="group" class="mb-10">
                <h2 class="text-sm font-black uppercase text-slate-900 mb-4 ml-4 italic tracking-tighter">{{ group }}</h2>
                <div class="bg-white rounded-[2.5rem] shadow-sm border border-slate-100 overflow-hidden">
                    <table class="w-full text-left table-fixed">
                        <thead class="bg-slate-50 border-b border-slate-100">
                            <tr class="text-[10px] font-black uppercase text-slate-400">
                                <th class="w-1/3 px-8 py-5">Item Details</th>
                                <th class="px-8 py-5 text-center">Rig Qty</th>
                                <th class="px-8 py-5 text-center">Warehouse Stock</th>
                                <th class="px-8 py-5 text-center">Status</th>
                                <th class="px-8 py-5 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-50">
                            <tr v-for="part in parts" :key="part.id" class="hover:bg-slate-50/50 transition-colors group">
                                <td class="px-8 py-6">
                                    <div class="font-bold text-slate-700 leading-tight">{{ part.name }}</div>
                                    <div class="text-[9px] font-mono text-slate-400 mt-1 uppercase">{{ part.serial_number }}</div>
                                </td>

                                <td class="px-8 py-6 text-center">
                                    <div class="flex flex-col items-center justify-center h-12">
                                        <span class="text-sm font-black text-slate-900">{{ part.quantity }}</span>
                                        <span class="text-[8px] font-black uppercase text-slate-400">On Rig</span>
                                    </div>
                                </td>

                                <td class="px-8 py-6">
                                    <div class="flex items-center justify-center h-12">
                                        <input type="number" v-model="part.warehouse_stock"
                                               @change="updateWhStock(part.serial_number, part.warehouse_stock)"
                                               class="w-20 h-10 text-center font-black text-indigo-700 bg-indigo-50 border border-indigo-100 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:bg-white transition-all" />
                                    </div>
                                </td>

                                <td class="px-8 py-6 text-center">
                                    <div class="flex items-center justify-center h-12">
                                        <span class="px-4 py-1 bg-emerald-100 text-emerald-700 rounded-full text-[9px] font-black uppercase tracking-widest">
                                            Working
                                        </span>
                                    </div>
                                </td>

                                <td class="px-8 py-6 text-right">
                                    <button @click="handleUnlink(part.id)" class="text-red-400 hover:text-red-600 font-black text-[10px] uppercase">Unlink</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref } from 'vue';
import { useForm, router } from '@inertiajs/vue3';

const props = defineProps({
    rig: Object,
    sparesGrouped: Object,
    existingGroups: Array
});

const isNewGroup = ref(false);

const linkForm = useForm({
    new_part_name: '',
    part_number: '',
    functional_group: '',
    quantity_to_add: 1,
});

const submitLink = () => {
    linkForm.post(`/inventory/rig/${props.rig.id}/add-spare`, {
        preserveScroll: true,
        onSuccess: () => {
            linkForm.reset();
            linkForm.quantity_to_add = 1;
            isNewGroup.value = false;
        },
    });
};

const updateWhStock = (sn, qty) => {
    router.post('/inventory/stock-update', { serial_number: sn, quantity: qty }, { preserveScroll: true });
};

const handleFileUpload = (event) => {
    const files = event.target.files;
    const formData = new FormData();
    for (let i = 0; i < files.length; i++) { formData.append('documents[]', files[i]); }
    router.post(`/inventory/rig/${props.rig.id}/upload-manuals`, formData, { forceFormData: true, preserveScroll: true });
};

const deleteDoc = (id) => {
    if(confirm('Delete this manual?')) { router.delete(`/inventory/documents/${id}`, { preserveScroll: true }); }
};

const handleUnlink = (id) => {
    if(confirm('Unlink this part from rig?')) { router.post(`/inventory/spare/${id}/unlink`, { preserveScroll: true }); }
};
</script>
