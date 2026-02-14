<script setup>
import { ref, watch } from 'vue';
import { useForm, Head, Link, router } from '@inertiajs/vue3';
import { debounce } from 'lodash';

const props = defineProps({
    depoSpares: Object,
    allRigs: Array,
    sites: Array
});

// --- STATE ---
const showLinkModal = ref(false);
const linkingSpare = ref(null);
const searchQuery = ref(new URLSearchParams(window.location.search).get('search') || '');

const linkForm = useForm({
    spare_id: '',
    parent_id: '',
});

// --- SEARCH ---
watch(searchQuery, debounce((value) => {
    router.get(route('inventory.depo'), { search: value }, {
        preserveState: true,
        replace: true,
        preserveScroll: true
    });
}, 300));

// --- METHODS ---
const openLinkModal = (spare) => {
    linkingSpare.value = spare;
    linkForm.spare_id = spare.id;
    linkForm.parent_id = '';
    showLinkModal.value = true;
};

const submitLink = () => {
    linkForm.post('/inventory/link-spare', {
        preserveScroll: true,
        onSuccess: () => {
            showLinkModal.value = false;
            linkForm.reset();
        }
    });
};
</script>

<template>
    <Head title="Depo Inventory" />

    <div class="min-h-screen bg-gray-50 p-4 md:p-8">
        <div class="max-w-7xl mx-auto">
            <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-200 mb-6 flex flex-col md:flex-row justify-between items-center gap-4">
                <div>
                    <h1 class="text-2xl font-black uppercase italic text-emerald-800 leading-none">Depo & Spares</h1>
                    <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-2">Inventory Management</p>
                </div>
                <input v-model="searchQuery" placeholder="Search serials..." class="rounded-xl border-gray-200 text-sm px-4 py-2 w-full md:w-64 focus:ring-emerald-500" />
            </div>

            <div class="bg-white rounded-3xl shadow-sm border border-gray-200 overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-gray-50 border-b">
                        <tr class="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            <th class="px-6 py-5">Spare / Attachment</th>
                            <th class="px-6 py-5">Current Location</th>
                            <th class="px-6 py-5 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 text-sm">
                        <tr v-for="item in depoSpares.data" :key="item.id" class="hover:bg-gray-50/50">
                            <td class="px-6 py-4">
                                <div class="font-bold text-gray-800">{{ item.name }}</div>
                                <div class="text-[10px] font-mono text-emerald-600 font-bold uppercase">{{ item.serial_number }}</div>

                                <div class="mt-1 flex gap-1">
                                    <span v-if="item.parent" class="text-[8px] bg-blue-50 text-blue-600 px-2 py-0.5 rounded-full font-black uppercase border border-blue-100">
                                        Linked to: {{ item.parent.name }}
                                    </span>
                                    <span v-else class="text-[8px] bg-gray-50 text-gray-400 px-2 py-0.5 rounded-full font-black uppercase border border-gray-200">
                                        Available in Stock
                                    </span>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <span class="text-gray-700 font-bold text-xs">
                                    {{ item.current_site?.location_name || 'Warehouse' }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-right">
                                <button v-if="!item.parent" @click="openLinkModal(item)" class="text-emerald-600 font-black text-[10px] uppercase underline hover:text-emerald-800">
                                    Link to Rig
                                </button>
                                <span v-else class="text-[10px] font-bold text-gray-300 uppercase italic">In Use</span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div v-if="depoSpares.links.length > 3" class="flex justify-center gap-1 py-8">
                <Link v-for="(link, k) in depoSpares.links" :key="k" :href="link.url || '#'" v-html="link.label"
                      class="px-4 py-2 rounded-xl text-xs font-bold border transition-all"
                      :class="[link.active ? 'bg-emerald-600 text-white' : 'bg-white text-gray-600', !link.url ? 'opacity-30' : 'hover:border-emerald-300']" />
            </div>
        </div>
    </div>

    <div v-if="showLinkModal" class="fixed inset-0 bg-slate-900/70 flex items-center justify-center z-50 p-4 backdrop-blur-sm">
        <div class="bg-white rounded-[2rem] shadow-2xl w-full max-w-md p-8">
            <h3 class="text-xl font-black uppercase italic text-gray-900 mb-6">Attach to Machine</h3>
            <form @submit.prevent="submitLink" class="space-y-4">
                <div>
                    <label class="text-[9px] font-bold uppercase text-gray-400 ml-2">Select Rig</label>
                    <select v-model="linkForm.parent_id" class="w-full border-gray-200 rounded-xl text-sm focus:ring-emerald-500" required>
                        <option value="">Choose a rig...</option>
                        <option v-for="rig in allRigs" :key="rig.id" :value="rig.id">
                            {{ rig.name }} ({{ rig.serial_number }})
                        </option>
                    </select>
                </div>
                <div class="flex gap-3 pt-4">
                    <button type="button" @click="showLinkModal = false" class="flex-1 py-4 bg-gray-100 text-gray-500 rounded-2xl font-black uppercase text-[10px]">Cancel</button>
                    <button type="submit" class="flex-1 py-4 bg-emerald-600 text-white rounded-2xl font-black uppercase text-[10px]" :disabled="linkForm.processing">Link Now</button>
                </div>
            </form>
        </div>
    </div>
</template>
