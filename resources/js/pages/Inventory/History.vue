<script setup>
import { Head, Link } from '@inertiajs/vue3';

defineProps({ equipment: Object });
</script>

<template>
    <Head :title="`History - ${equipment.name}`" />
    <div class="p-8 max-w-4xl mx-auto">
        <div class="flex justify-between mb-6">
            <h1 class="text-2xl font-bold">Movement History: {{ equipment.serial_number }}</h1>
            <Link href="/inventory" class="text-blue-600">← Back</Link>
        </div>

        <div class="space-y-4">
            <div v-for="log in equipment.movements" :key="log.id" class="bg-white p-4 shadow rounded-lg border-l-4 border-indigo-500">
                <div class="flex justify-between">
                    <span class="font-bold text-gray-700">
                        {{ log.from_site?.location_name || 'Initial' }}
                        <span class="text-indigo-500 mx-2">➔</span>
                        {{ log.to_site?.location_name }}
                    </span>
                    <span class="text-sm text-gray-500">{{ log.transfer_date }}</span>
                </div>
            </div>
        </div>
    </div>
</template>
