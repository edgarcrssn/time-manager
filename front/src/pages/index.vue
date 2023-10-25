<template>
    <div class="p-2 flex flex-col items-center">
        <h1 class="text-3xl font-bold underline">Time Manager</h1>

        <ClockManager :userId="userId" />

        <ChartManager :userId="userId"/>
    </div>
</template>

<script lang="ts">
import { ref } from 'vue';
import ClockManager from '../components/ClockManager.vue';
import ChartManager from '../components/ChartManager.vue';

export default {
    name: 'Dashboard',
    components: {
        ChartManager,
        ClockManager,
    },
    setup() {
        const userId = ref('3');
        const username = ref('user3');

        return {
            userId,
            username
        };
    }
}
</script>