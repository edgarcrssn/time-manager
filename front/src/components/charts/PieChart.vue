<template>
    <Pie :data="chartData" :options="chartOptions" />
</template>
  
<script lang="ts" setup>
import { Pie } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, ArcElement } from 'chart.js'
import { defineProps } from 'vue';

ChartJS.register(Title, Tooltip, Legend, ArcElement)

const { chartData, chartOptions } = defineProps(['chartData', 'chartOptions']);
</script>

  