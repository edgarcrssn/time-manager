<template>
  <Bar :data="chartData" :options="chartOptions" />
</template>

<script lang="ts" setup>
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js'
import { defineProps } from 'vue';

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)

const { chartData, chartOptions } = defineProps(['chartData', 'chartOptions']);
</script>
