<template>
    <div>
        <h1 class="text-3xl font-bold underline">Time Manager</h1>
        <BarChart />

        <ClockManager :userId="userId" />
    </div>
</template>

<script lang="ts">
import { ref } from 'vue';
import BarChart from '../components/charts/BarChart.vue';
import ClockManager from '../components/ClockManager.vue';

export default {
    name: 'Dashboard',
    components: {
        BarChart,
        ClockManager,
    },
    setup() {
        const userId = ref('3');

        return {
            userId
        };
    }
}
</script>