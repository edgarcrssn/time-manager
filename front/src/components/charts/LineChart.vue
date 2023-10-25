<template>
    <Line :data="chartData" :options="chartOptions" />
</template>
  
<script lang="ts">
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, PointElement, LineElement } from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, PointElement, LineElement)

export default {
    name: 'LineChart',
    components: { Line },
    props: {
        chartData: {
            type: Object,
            required: true
        },
        chartOptions: {
            type: Object,
        }
    }
}
</script>  