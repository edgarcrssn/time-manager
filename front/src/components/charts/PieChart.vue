<template>
    <Pie :data="chartData" :options="chartOptions" />
</template>
  
<script lang="ts">
import { Pie } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, ArcElement } from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, ArcElement)

export default {
    name: 'PieChart',
    components: { Pie },
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
  