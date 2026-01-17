<script setup>
import { useForm, Head, Link } from '@inertiajs/vue3';
import { computed } from 'vue';

// props received from InventoryController@transfer
const props = defineProps({
    equipmentList: Array,
    sites: Array
});

const form = useForm({
    equipment_id: '',
    to_site_id: '',
    transfer_date: new Date().toISOString().substr(0, 10), // Default to today
    remarks: ''
});

// Logic to find the current location of the selected machine
const selectedEquipment = computed(() => {
    return props.equipmentList.find(item => item.id == form.equipment_id);
});

const submit = () => {
    form.post('/inventory/transfer', {
        onSuccess: () => {
            // Optional: reset form or show success message
        },
    });
};
</script>

<template>
    <Head title="Transfer Equipment" />

    <div class="min-h-screen bg-gray-100 p-8">
        <div class="max-w-2xl mx-auto bg-white p-8 rounded-xl shadow-lg">

            <div class="flex items-center justify-between mb-8 border-b pb-4">
                <h2 class="text-2xl font-bold text-gray-800">Move Piling Equipment</h2>
                <Link href="/inventory" class="text-indigo-600 hover:text-indigo-800 font-medium">
                    &larr; Back to Inventory
                </Link>
            </div>

            <form @submit.prevent="submit" class="space-y-6">

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Select Machine/Rig</label>
                    <select v-model="form.equipment_id"
                            class="w-full border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                            required>
                        <option value="">-- Choose Equipment --</option>
                        <option v-for="item in equipmentList" :key="item.id" :value="item.id">
                            {{ item.name }} ({{ item.serial_number }})
                        </option>
                    </select>
                    <div v-if="form.errors.equipment_id" class="text-red-500 text-xs mt-1">{{ form.errors.equipment_id }}</div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                    <div>
                        <label class="block text-sm font-semibold text-gray-500 mb-1">From (Current Location)</label>
                        <div class="p-3 bg-gray-100 border border-gray-200 rounded-lg text-gray-600 italic">
                            {{ selectedEquipment ? selectedEquipment.current_site?.location_name : 'Please select equipment' }}
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold text-indigo-700 mb-1">To (Destination Site)</label>
                        <select v-model="form.to_site_id"
                                class="w-full border-indigo-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                                required>
                            <option value="">-- Select Destination --</option>
                            <option v-for="site in sites" :key="site.id" :value="site.id">
                                {{ site.location_name }}
                            </option>
                        </select>
                        <div v-if="form.errors.to_site_id" class="text-red-500 text-xs mt-1">{{ form.errors.to_site_id }}</div>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Transfer Date</label>
                        <input type="date" v-model="form.transfer_date"
                               class="w-full border-gray-300 rounded-lg shadow-sm" required />
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Remarks (Optional)</label>
                        <input type="text" v-model="form.remarks" placeholder="e.g. Moved for Project A"
                               class="w-full border-gray-300 rounded-lg shadow-sm" />
                    </div>
                </div>

                <div class="pt-4">
                    <button type="submit"
                            :disabled="form.processing"
                            class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3 px-4 rounded-lg transition duration-200 disabled:opacity-50">
                        <span v-if="form.processing">Updating Database...</span>
                        <span v-else>Confirm & Log Transfer</span>
                    </button>
                </div>

            </form>
        </div>
    </div>
</template>
