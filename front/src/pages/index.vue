<template>
    <div>
        <h1 className="text-3xl font-bold underline">
            Time Manager
        </h1>
        <BarChart />
    </div>
</template>

<script lang="ts">
import BarChart from '../components/charts/BarChart.vue'

export default {
  name: 'App',
  components: { BarChart }
}
</script>