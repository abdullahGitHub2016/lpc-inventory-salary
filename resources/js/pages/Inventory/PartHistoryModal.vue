<template>
  <div v-if="show" class="fixed inset-0 z-[150] flex items-center justify-center p-4">
    <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" @click="$emit('close')"></div>

    <div class="relative bg-white w-full max-w-2xl rounded-[32px] shadow-2xl overflow-hidden animate-pop-in">
      <div class="p-8 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
        <div>
          <h3 class="text-xl font-black italic uppercase tracking-tighter text-slate-900">Maintenance History</h3>
          <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1">Serial: {{ serialNumber }}</p>
        </div>
        <button @click="$emit('close')" class="text-slate-300 hover:text-red-500 transition-colors text-2xl">&times;</button>
      </div>

      <div class="p-8 max-h-[60vh] overflow-y-auto">
        <div v-if="loading" class="flex flex-col items-center justify-center py-12">
          <div class="animate-spin rounded-full h-8 w-8 border-4 border-indigo-500/30 border-t-indigo-600 mb-4"></div>
          <p class="text-[10px] font-black uppercase text-slate-400 tracking-widest">Fetching Logs...</p>
        </div>

        <div v-else-if="logs.length === 0" class="text-center py-12">
          <p class="text-slate-400 font-bold uppercase text-[10px] tracking-widest">No history recorded for this component</p>
        </div>

        <div v-else class="space-y-6">
          <div v-for="log in logs" :key="log.id" class="relative pl-8 border-l-2 border-slate-100 pb-2">
            <div :class="['absolute -left-[9px] top-0 h-4 w-4 rounded-full border-4 border-white shadow-sm', getIconColor(log.action)]"></div>

            <div class="flex justify-between items-start mb-1">
              <span class="text-[10px] font-black uppercase tracking-tight text-slate-900">{{ log.action }}</span>
              <span class="text-[9px] font-bold text-slate-400">{{ formatDate(log.created_at) }}</span>
            </div>

            <p class="text-xs text-slate-600 leading-relaxed font-medium bg-slate-50 p-3 rounded-xl border border-slate-100">
              {{ log.notes || 'No technical notes provided.' }}
            </p>

            <div class="mt-2 flex items-center gap-4 text-[9px] font-bold uppercase text-slate-400 tracking-tighter">
              <span>By: {{ log.user?.name || 'System' }}</span>
              <span v-if="log.location_to">Loc: {{ log.location_to }}</span>
            </div>
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

// --- HELPERS (The missing functions) ---

const getIconColor = (action) => {
  const colors = {
    'Maintenance': 'bg-blue-500',
    'Repair': 'bg-red-500',
    'Adjustment': 'bg-amber-500',
    'QC Inspection': 'bg-emerald-500',
    'Troubleshooting': 'bg-indigo-500'
  };
  return colors[action] || 'bg-slate-400';
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  return new Date(dateString).toLocaleDateString('en-GB', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
};

const fetchLogs = async () => {
  if (!props.serialNumber) {
    loading.value = false;
    return;
  }

  loading.value = true;
  try {
    const response = await axios.get(`/api/inventory-logs/${props.serialNumber}`);
    logs.value = response.data;
  } catch (error) {
    console.error("History Fetch Error:", error);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchLogs();
});
</script>

<style scoped>
@keyframes pop-in {
  0% { opacity: 0; transform: scale(0.95); }
  100% { opacity: 1; transform: scale(1); }
}
.animate-pop-in {
  animation: pop-in 0.2s ease-out forwards;
}
</style>
