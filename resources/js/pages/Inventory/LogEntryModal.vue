<template>
    <div v-if="show" class="fixed inset-0 z-[120] flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" @click="$emit('close')"></div>

        <div class="relative bg-white w-full max-w-lg rounded-3xl shadow-2xl overflow-hidden animate-pop-in">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50 flex justify-between items-center">
                <div>
                    <h3 class="text-lg font-black italic uppercase tracking-tighter text-slate-900">Create Log Entry
                    </h3>
                    <p class="text-[10px] font-bold text-slate-400 uppercase">Part: {{ part?.name }} ({{
                        part?.serial_number }})</p>
                </div>
                <button @click="$emit('close')" class="text-slate-400 hover:text-red-500 text-2xl">&times;</button>
            </div>

            <form @submit.prevent="submitLog" class="p-6 space-y-4">
                <div>
                    <label class="text-[10px] font-black uppercase text-slate-500 ml-1">Action Type</label>
                    <select v-model="form.action"
                        class="w-full mt-1 bg-slate-50 border-slate-200 rounded-xl text-sm font-bold focus:ring-indigo-500 transition-all">
                        <option value="Maintenance">Maintenance</option>
                        <option value="Troubleshooting">Troubleshooting</option>
                        <option value="QC Inspection">QC Inspection</option>
                        <option value="Repair">Repair</option>
                        <option value="Adjustment">Adjustment</option>
                    </select>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="text-[10px] font-black uppercase text-slate-500 ml-1">Location To</label>
                        <input v-model="form.location_to" type="text"
                            class="w-full mt-1 bg-slate-50 border-slate-200 rounded-xl text-sm p-2"
                            placeholder="e.g. Soilmec SR-40">
                    </div>
                    <div>
                        <label class="text-[10px] font-black uppercase text-slate-500 ml-1">Qty Change</label>
                        <input v-model="form.quantity_change" type="number"
                            class="w-full mt-1 bg-slate-50 border-slate-200 rounded-xl text-sm p-2">
                    </div>
                </div>

                <div>
                    <label class="text-[10px] font-black uppercase text-slate-500 ml-1">Technician Notes</label>
                    <textarea v-model="form.notes" rows="3"
                        class="w-full mt-1 bg-slate-50 border-slate-200 rounded-2xl text-sm p-3 focus:ring-indigo-500"
                        placeholder="Describe the work done..."></textarea>
                </div>

                <button type="submit" :disabled="loading"
                    class="w-full py-4 bg-indigo-600 hover:bg-indigo-700 text-white rounded-2xl font-black uppercase tracking-widest text-xs shadow-lg shadow-indigo-200 transition-all flex justify-center items-center gap-2">
                    <span v-if="loading"
                        class="animate-spin border-2 border-white/30 border-t-white rounded-full h-4 w-4"></span>
                    {{ loading ? 'Saving...' : 'Save Log Entry' }}
                </button>
            </form>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import axios from 'axios';

const props = defineProps({ show: Boolean, part: Object });
const emit = defineEmits(['close', 'saved']);
const loading = ref(false);

const form = reactive({
    action: 'Maintenance',
    location_from: 'Soilmec SR-40',
    location_to: 'Soilmec SR-40',
    quantity_change: 0,
    notes: ''
});

// Inside submitLog function
const submitLog = async () => {
    loading.value = true;
    try {
        // Relative path works best with Laravel/Inertia setups
        await axios.post('/api/inventory-logs', {
            ...form,
            serial_number: props.part.serial_number,
            equipment_id: props.part.id
        });

        emit('saved');
        emit('close');
    } catch (e) {
        console.error("Submission Error:", e.response);
        alert("System could not find the logging endpoint (404).");
    } finally {
        loading.value = false;
    }
};
</script>
