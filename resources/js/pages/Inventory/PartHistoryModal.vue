<template>
    <div v-if="show" class="fixed inset-0 z-[150] flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" @click="$emit('close')"></div>

        <div class="relative bg-white w-full max-w-2xl rounded-[32px] shadow-2xl overflow-hidden animate-pop-in">

            <div class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
                <div>
                    <h3
                        class="text-xl font-black italic uppercase tracking-tighter text-slate-900 flex items-center gap-2">
                        <span class="text-indigo-600">⚡</span> Maintenance AI
                    </h3>
                    <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1">Serial: {{
                        serialNumber }}</p>
                </div>
                <button @click="$emit('close')"
                    class="text-slate-300 hover:text-red-500 transition-colors text-2xl">&times;</button>
            </div>

            <div class="p-6 bg-slate-900 shadow-xl">
                <div class="flex gap-2">
                    <div class="relative flex-1">
                        <input v-model="aiQuestion" @keyup.enter="askAI"
                            placeholder="Ask AI: 'When was the last repair?' or 'Summarize issues'..."
                            class="w-full bg-slate-800 border-none text-white text-xs rounded-xl py-3 px-4 focus:ring-2 focus:ring-indigo-500 placeholder:text-slate-500"
                            :disabled="aiLoading" />
                        <div v-if="aiLoading" class="absolute right-3 top-3">
                            <div
                                class="animate-spin h-4 w-4 border-2 border-indigo-500 border-t-transparent rounded-full">
                            </div>
                        </div>
                    </div>
                    <button @click="askAI" :disabled="aiLoading || !aiQuestion"
                        class="bg-indigo-600 hover:bg-indigo-500 disabled:bg-slate-700 text-white px-6 py-2 rounded-xl text-[10px] font-black uppercase transition-all shadow-lg shadow-indigo-500/20">
                        Ask
                    </button>
                </div>

                <Transition name="fade">
                    <div v-if="aiAnswer"
                        class="mt-4 p-4 bg-indigo-500/10 border border-indigo-500/20 rounded-2xl relative">
                        <button @click="aiAnswer = ''"
                            class="absolute top-2 right-2 text-indigo-300 hover:text-white text-lg">&times;</button>
                        <p class="text-[9px] text-indigo-400 font-black uppercase mb-2 flex items-center gap-1">
                            <span class="animate-pulse">●</span> AI Technical Analysis
                        </p>
                        <p class="text-xs text-indigo-50 text-slate-300 leading-relaxed font-medium">
                            {{ aiAnswer }}
                        </p>
                    </div>
                </Transition>
            </div>

            <div class="p-6 max-h-[50vh] overflow-y-auto bg-white">
                <div class="flex items-center justify-between mb-6">
                    <h4 class="text-[10px] font-black uppercase tracking-widest text-slate-400">Standard History Logs
                    </h4>
                    <div class="h-px flex-1 bg-slate-100 ml-4"></div>
                </div>

                <div v-if="loading" class="flex flex-col items-center justify-center py-12">
                    <div class="animate-spin rounded-full h-8 w-8 border-4 border-slate-100 border-t-indigo-600 mb-4">
                    </div>
                </div>

                <div v-else-if="logs.length === 0" class="text-center py-12">
                    <p class="text-slate-400 font-bold uppercase text-[10px] tracking-widest">No history recorded</p>
                </div>

                <div v-else class="space-y-6">
                    <div v-for="log in logs" :key="log.id" class="relative pl-8 border-l-2 border-slate-100 pb-2">
                        <div
                            :class="['absolute -left-[9px] top-0 h-4 w-4 rounded-full border-4 border-white shadow-sm', getIconColor(log.action)]">
                        </div>

                        <div class="flex justify-between items-start mb-1">
                            <span class="text-[10px] font-black uppercase tracking-tight text-slate-900">{{ log.action
                                }}</span>
                            <span class="text-[9px] font-bold text-slate-400">{{ formatDate(log.created_at) }}</span>
                        </div>

                        <p class="text-xs text-slate-600 font-medium bg-slate-50 p-3 rounded-xl border border-slate-50">
                            {{ log.notes || 'Routine update.' }}
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const props = defineProps({
    show: Boolean,
    serialNumber: String
});

const emit = defineEmits(['close']);

const logs = ref([]);
const loading = ref(true);
const aiQuestion = ref('');
const aiAnswer = ref('');
const aiLoading = ref(false);

// --- 1. Fetch Logs for Timeline ---
const fetchLogs = async () => {
    if (!props.serialNumber) return;
    loading.value = true;
    try {
        const response = await axios.get(`/api/inventory-logs/${props.serialNumber}`);
        logs.value = response.data;
    } catch (error) {
        console.error("Fetch Error:", error);
    } finally {
        loading.value = false;
    }
};

// --- 2. Ask OpenAI for Analysis ---
const askAI = async () => {
    aiLoading.value = true;
    try {
        const response = await axios.post(`/api/inventory/ai-search/${props.serialNumber}`, {
            question: aiQuestion.value
        }, { timeout: 120000 });

        // Safety check: Is this JSON or a login page?
        if (typeof response.data === 'string' && response.data.includes('<!DOCTYPE html>')) {
            aiAnswer.value = "Error: Session expired. Please refresh the page.";
            return;
        }

        aiAnswer.value = response.data.answer;
    } catch (error) {
        console.error("AI Error:", error);
        aiAnswer.value = "AI Error: " + (error.response?.data?.message || "Check server logs.");
    } finally {
        aiLoading.value = false;
    }
};

// --- Helpers ---
const getIconColor = (action) => {
    const colors = {
        'Repair': 'bg-red-500',
        'Maintenance': 'bg-blue-500',
        'Adjustment': 'bg-amber-500',
        'Inspection': 'bg-emerald-500'
    };
    return colors[action] || 'bg-slate-400';
};

const formatDate = (date) => {
    return new Date(date).toLocaleDateString('en-GB', {
        day: '2-digit', month: 'short', year: 'numeric'
    });
};

onMounted(fetchLogs);
</script>

<style scoped>
@keyframes pop-in {
    0% {
        opacity: 0;
        transform: scale(0.95);
    }

    100% {
        opacity: 1;
        transform: scale(1);
    }
}

.animate-pop-in {
    animation: pop-in 0.2s ease-out forwards;
}

.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.3s;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}
</style>
