<template>
    <div class="p-8 bg-gray-50 min-h-screen">
        <div class="max-w-7xl mx-auto">
            <div class="flex justify-between items-end mb-8">
                <div>
                    <h1 class="text-2xl font-black text-slate-800 uppercase">Depo Spares Inventory</h1>
                    <p class="text-sm text-slate-500 font-bold uppercase tracking-widest">Unassigned Attachments & Parts</p>
                </div>
                <div class="bg-indigo-600 text-white px-4 py-2 rounded-xl font-bold text-xs">
                    TOTAL STOCK: {{ spares.length }}
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div v-for="spare in spares" :key="spare.id" class="bg-white p-6 rounded-3xl shadow-sm border border-slate-200">
                    <div class="flex justify-between items-start mb-4">
                        <div class="p-3 bg-slate-100 rounded-2xl text-slate-600">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 4a2 2 0 114 0v1a1 1 0 001 1h3a1 1 0 011 1v3a1 1 0 01-1 1h-1a2 2 0 100 4h1a1 1 0 011 1v3a1 1 0 01-1 1h-3a1 1 0 01-1-1v-1a2 2 0 10-4 0v1a1 1 0 01-1 1H7a1 1 0 01-1-1v-3a1 1 0 00-1-1H4a2 2 0 110-4h1a1 1 0 001-1V7a1 1 0 011-1h3a1 1 0 001-1V4z" />
                            </svg>
                        </div>
                        <span class="px-3 py-1 bg-blue-50 text-blue-600 rounded-full text-[10px] font-black uppercase border border-blue-100">In Stock</span>
                    </div>

                    <h3 class="font-black text-slate-800 uppercase text-lg mb-1">{{ spare.name }}</h3>
                    <p class="text-mono text-[10px] text-indigo-500 font-bold mb-4 uppercase tracking-tighter">SN: {{ spare.serial_number }}</p>

                    <div class="pt-4 border-t border-slate-50 flex justify-between items-center">
                        <span class="text-[10px] font-bold text-slate-400 uppercase">Location: Depo / Yard</span>
                        <button @click="assignToRig(spare)" class="text-indigo-600 font-black text-[10px] uppercase hover:underline">Issue to Rig</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
defineProps({ spares: Array, sites: Array });

const assignToRig = (spare) => {
    // Logic to open a modal and select which Rig to attach this spare to
    alert('Logic to assign ' + spare.name + ' to a Rig');
};
</script>
