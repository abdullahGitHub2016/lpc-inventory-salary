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
</script>

<template>
    <div class="p-6 bg-slate-50 min-h-screen font-sans">

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
                                <td class="px-8 py-5 font-bold text-slate-700">{{ part.name }}</td>
                                <td class="px-8 py-5">
                                    <span class="font-mono text-xs bg-slate-100 px-3 py-1 rounded-md text-slate-600">{{
                                        part.serial_number }}</span>
                                </td>
                                <td class="px-8 py-5">
                                    <span
                                        class="text-[9px] font-black uppercase px-3 py-1 rounded-full border border-emerald-200 bg-emerald-50 text-emerald-600">
                                        {{ part.status }}
                                    </span>
                                </td>
                                <td class="px-8 py-5 text-right">
                                    <button @click="handleUnlink(part.id)"
                                        class="text-slate-300 hover:text-red-500 font-black text-[10px] uppercase transition">
                                        Unlink
                                    </button>
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
