<script setup>
import { Link } from '@inertiajs/vue3';

defineProps({
    links: Array,
});
</script>

<template>
    <div v-if="links.length > 3">
        <div class="flex flex-wrap -mb-1 justify-center gap-1">
            <template v-for="(link, key) in links" :key="key">
                <div v-if="link.url === null"
                     class="mr-1 mb-1 px-4 py-3 text-xs leading-4 text-gray-400 border rounded-xl"
                     v-html="link.label" />

                <Link v-else
                      class="mr-1 mb-1 px-4 py-3 text-xs leading-4 border rounded-xl hover:bg-white focus:border-indigo-500 focus:text-indigo-500 transition-all font-bold"
                      :class="{ 'bg-indigo-600 text-white border-indigo-600': link.active, 'bg-white text-slate-600 border-slate-200': !link.active }"
                      :href="link.url"
                      v-html="link.label" />
            </template>
        </div>
    </div>
</template>
