<template>
  <Line :data="chartData" :options="chartOptions" />
</template>

<script lang="ts" setup>
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, PointElement, LineElement } from 'chart.js'
import { defineProps } from 'vue';

ChartJS.register(Title, Tooltip, Legend, PointElement, LineElement)

const { chartData, chartOptions } = defineProps(['chartData', 'chartOptions']);
</script>