<script setup>
import { ref, watch } from 'vue';
import { useForm, router, Link } from '@inertiajs/vue3';
import axios from 'axios';
import debounce from 'lodash/debounce'; // Optional: npm install lodash

const props = defineProps({
    rig: Object,
    sparesGrouped: Object,     // Spares already on this rig
    warehouseSpares: Array,   // Spares available to link
    existingGroups: Array      // Unique group names for suggestions
});

const showAddForm = ref(false);
const partStatusMessage = ref('');
const isDuplicateOnOtherRig = ref(false);

const linkForm = useForm({
    spare_id: '',
    new_part_name: '',
    part_number: '',       // Serial Number in DB
    functional_group: '',
});

// 1. Real-time Lookup Logic
// Inside your checkPartNumber function
const checkPartNumber = debounce(async (value) => {
    // If the input is cleared, unlock everything
    if (!value || value.length < 1) {
        partStatusMessage.value = '';
        isDuplicateOnOtherRig.value = false;
        linkForm.spare_id = ''; // This unlocks the description field
        linkForm.new_part_name = '';
        return;
    }

    try {
        const response = await axios.get(`/inventory/lookup-part/${value}`);
        const { exists, part, is_attached } = response.data;

        if (exists) {
            if (is_attached) {
                isDuplicateOnOtherRig.value = true;
                partStatusMessage.value = `❌ Already on ${part.parent.name}`;
                linkForm.spare_id = part.id; // Keep ID to prevent "New Part" creation
            } else {
                isDuplicateOnOtherRig.value = false;
                linkForm.spare_id = part.id; // Locks the field
                linkForm.new_part_name = part.name; // Auto-fills the field
                partStatusMessage.value = `✅ Found in Warehouse`;
            }
        } else {
            // TRULY NEW PART - Unlock everything
            isDuplicateOnOtherRig.value = false;
            linkForm.spare_id = ''; // This UNLOCKS the description field
            partStatusMessage.value = '✨ New Part (needs description)';
        }
    } catch (e) {
        linkForm.spare_id = ''; // Safety unlock on error
    }
}, 500);

// Watcher for the part number input
watch(() => linkForm.part_number, (newVal) => {
    checkPartNumber(newVal);
});

// 2. Actions
const submitEntry = () => {
    linkForm.post(route('inventory.rig.add-spare', props.rig.id), {
        onSuccess: () => {
            linkForm.reset();
            partStatusMessage.value = '';
            showAddForm.value = false;
        },
    });
};

const handleUnlink = (id) => {
    if (confirm("Move this part back to Warehouse?")) {
        router.post(`/inventory/unlink-spare/${id}`, {}, { preserveScroll: true });
    }
};

const handleFileUpload = (event) => {
    const files = event.target.files;
    if (!files.length) return;

    const formData = new FormData();
    // Rig ID 152
    formData.append('equipment_id', props.rig.id);

    // Append all selected files
    for (let i = 0; i < files.length; i++) {
        formData.append('documents[]', files[i]); // <--- Ensure this name matches the Controller
    }

    // Send to server via Inertia or Axios
    router.post(`/inventory/rig/${props.rig.id}/upload-manuals`, formData, {
        forceFormData: true,
        preserveScroll: true,
        onSuccess: () => {
            console.log("Manuals uploaded successfully");
        }
    });
};

const deleteDoc = (docId) => {
    if (confirm("Are you sure you want to remove this manual?")) {
        router.delete(`/inventory/documents/${docId}`, {
            preserveScroll: true,
            onSuccess: () => {
                console.log("Document removed");
            }
        });
    }
};
</script>

<template>
    <div class="p-6 bg-slate-50 min-h-screen font-sans">
        <div class="max-w-7xl mx-auto mb-10">
            <div class="bg-white rounded-[2.5rem] p-8 shadow-sm border border-slate-100">
                <div class="flex justify-between items-center mb-6">
                    <h3 class="text-xs font-black uppercase text-slate-400 tracking-widest italic">Technical Library &
                        Manuals</h3>

                    <input type="file" multiple class="hidden" ref="fileUpload" @change="handleFileUpload" />
                    <button @click="$refs.fileUpload.click()"
                        class="text-[10px] font-black uppercase text-indigo-600 hover:text-indigo-800 transition">
                        + Upload New Manual
                    </button>
                </div>

                <div v-if="rig.documents && rig.documents.length > 0"
                    class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4">
                    <div v-for="doc in rig.documents" :key="doc.id"
                        class="group flex items-center gap-4 p-4 bg-slate-50 rounded-2xl border border-transparent hover:border-indigo-200 hover:bg-white transition-all shadow-sm">

                        <div class="w-10 h-10 flex items-center justify-center rounded-xl bg-white shadow-sm text-lg">
                            {{ doc.file_type === 'pdf' ? '📕' : '📘' }}
                        </div>

                        <div class="flex flex-col overflow-hidden">
                            <span class="text-xs font-bold text-slate-700 truncate" :title="doc.file_name">
                                {{ doc.file_name }}
                            </span>
                            <div class="flex gap-3 mt-1">
                                <a :href="doc.file_path" target="_blank"
                                    class="text-[9px] font-black uppercase text-indigo-500 hover:underline">View</a>
                                <button @click="deleteDoc(doc.id)"
                                    class="text-[9px] font-black uppercase text-red-400 hover:text-red-600 opacity-0 group-hover:opacity-100 transition">Delete</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div v-else
                    class="text-center py-6 border-2 border-dashed border-slate-100 rounded-3xl text-slate-400 text-xs italic">
                    No manuals uploaded yet.
                </div>
            </div>
        </div>

        <div class="max-w-7xl mx-auto mb-8 flex justify-between items-end">
            <div>
                <Link href="/inventory" class="text-[10px] font-black uppercase text-slate-400 hover:text-indigo-600">←
                    Back to Fleet</Link>
                <h1 class="text-4xl font-black italic uppercase text-slate-900 mt-2">{{ rig.name }}</h1>
                <p class="text-indigo-600 font-mono font-bold">SERIAL NO: {{ rig.serial_number }}</p>
            </div>
            <button @click="showAddForm = !showAddForm"
                class="bg-slate-900 text-white px-8 py-4 rounded-2xl font-black uppercase text-xs hover:bg-indigo-600 transition-all shadow-lg">
                {{ showAddForm ? 'Close Form' : '+ Add Part from PDF' }}
            </button>
        </div>

        <div class="max-w-7xl mx-auto">

            <transition name="slide-down">
                <div v-if="showAddForm" class="bg-white p-8 rounded-[2.5rem] shadow-xl border border-slate-100 mb-10">
                    <h3 class="text-lg font-black uppercase italic mb-6 text-slate-800">Catalogue Entry</h3>

                    <form @submit.prevent="submitEntry" class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="flex flex-col">
                            <label class="text-[10px] font-black uppercase text-slate-400 ml-2 mb-1">Part Number (From
                                PDF)</label>
                            <input v-model="linkForm.part_number" placeholder="e.g. 47100162"
                                :class="{ 'border-red-500 bg-red-50': isDuplicateOnOtherRig }"
                                class="w-full border-slate-200 rounded-2xl text-sm p-4 focus:ring-indigo-500"
                                required />
                            <p v-if="partStatusMessage"
                                :class="isDuplicateOnOtherRig ? 'text-red-500' : 'text-emerald-500'"
                                class="text-[9px] font-bold uppercase mt-2 ml-2">
                                {{ partStatusMessage }}
                            </p>
                        </div>

                        <div class="flex flex-col">
                            <label class="text-[10px] font-black uppercase text-slate-400 ml-2 mb-1">Description</label>
                            <input v-model="linkForm.new_part_name"
                                :disabled="linkForm.spare_id !== '' && linkForm.spare_id !== null"
                                placeholder="e.g. Joystick"
                                class="w-full border-slate-200 rounded-2xl text-sm p-4 disabled:bg-slate-100 disabled:text-slate-500 shadow-inner"
                                required />
                        </div>

                        <div class="flex flex-col">
                            <label class="text-[10px] font-black uppercase text-slate-400 ml-2 mb-1">Functional
                                Group</label>
                            <input v-model="linkForm.functional_group" list="group-list" placeholder="e.g. Turret Group"
                                class="w-full border-slate-200 rounded-2xl text-sm p-4" required />
                            <datalist id="group-list">
                                <option v-for="group in existingGroups" :key="group" :value="group" />
                            </datalist>
                        </div>

                        <div class="md:col-span-3 flex justify-end gap-3 border-t pt-6">
                            <button type="submit" :disabled="isDuplicateOnOtherRig || linkForm.processing"
                                class="bg-indigo-600 text-white px-10 py-4 rounded-2xl font-black uppercase text-xs disabled:opacity-50 hover:bg-indigo-700 transition">
                                Confirm Entry
                            </button>
                        </div>
                    </form>
                </div>
            </transition>

            <div v-for="(parts, groupName) in sparesGrouped" :key="groupName" class="mb-12">
                <div class="flex items-center gap-4 mb-4">
                    <div
                        class="bg-slate-900 text-white px-4 py-1 rounded-lg text-[10px] font-black uppercase tracking-widest">
                        Section</div>
                    <h2 class="text-xl font-black uppercase italic text-slate-800">{{ groupName || 'General Components'
                        }}</h2>
                    <div class="flex-grow h-[2px] bg-slate-200"></div>
                </div>

                <div class="bg-white rounded-[2rem] border border-slate-200 shadow-sm overflow-hidden">
                    <table class="w-full text-left">
                        <thead class="bg-slate-50/50 border-b border-slate-100">
                            <tr class="text-[10px] font-black uppercase text-slate-400">
                                <th class="px-8 py-5">Description</th>
                                <th class="px-8 py-5">Part Number</th>
                                <th class="px-8 py-5">Status</th>
                                <th class="px-8 py-5 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-50">
                            <tr v-for="part in parts" :key="part.id" class="hover:bg-slate-50/80 transition-colors">
                                <td class="px-8 py-5 font-bold text-slate-700">
                                    {{ part.name }}
                                </td>
                                <td class="px-8 py-5 font-mono text-xs">
                                    {{ part.serial_number }}
                                </td>
                                <td class="px-8 py-5">
                                    <div class="flex flex-col">
                                        <span class="text-[10px] font-black uppercase text-slate-900">
                                            {{ rig.current_site?.location_name }}
                                        </span>
                                        <span class="text-[9px] text-slate-400 italic">Attached to Machine</span>
                                    </div>
                                </td>
                                <td class="px-8 py-5">
                                    <span v-if="part.global_stock_count > 0"
                                        class="text-indigo-600 font-bold text-[10px] bg-indigo-50 px-2 py-1 rounded">
                                        {{ part.global_stock_count }} More in Warehouse
                                    </span>
                                    <span v-else class="text-slate-300 text-[10px]">No extra stock</span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.3s ease-out;
}

.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-20px);
}
</style>
