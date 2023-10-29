<template>
  <section>
    <h2 class="text-3xl mt-4 mb-4">
      User {{ userId }}'s Charts
    </h2>

    <button @click="previousWeek">
      Previous Week
    </button>
    <button @click="nextWeek">
      Next Week
    </button>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 p-4">
      <div>
        <BarChart
          :data="barChartData"
          :options="chartOptions"
        />
      </div>
    </div>
  </section>
</template>

<script lang="ts" setup>
import { ref, onMounted, defineProps } from 'vue'
import BarChart from './charts/BarChart.vue'

const { userId } = defineProps(['userId'])

const barChartData = ref({
  labels: [],
  datasets: [{ data: [], label: 'Hours Worked', backgroundColor: 'blue' }]
})

const chartOptions = ref({
  responsive: true,
  maintainAspectRatio: false
})

const API_URL = `${import.meta.env.VITE_API_URL}/api/workingtimes/${userId}`

const currentDate = new Date()

const getWeekRange = (date) => {
  const monday =
    date.getDay() === 0
      ? new Date(date.setDate(date.getDate() - 6))
      : new Date(date.setDate(date.getDate() - date.getDay() + 1))
  const sunday = new Date(date.setDate(date.getDate() + 6))

  return { start: monday, end: sunday }
}

const fetchWeekData = async (date) => {
  const { start, end } = getWeekRange(date)

  const response = await fetch(API_URL)
  const data = await response.json()

  const weekData = data.filter((item) => {
    const startDate = new Date(item.start).toISOString().split('T')[0]
    return startDate >= start.toISOString().split('T')[0] && startDate <= end.toISOString().split('T')[0]
  })

  const aggregatedHours = {}

  weekData.forEach((item) => {
    const start = new Date(item.start)
    const end = new Date(item.end)
    const hours = (end - start) / (1000 * 60 * 60)
    const date = start.toISOString().split('T')[0]

    if (!aggregatedHours[date]) {
      aggregatedHours[date] = 0
    }
    aggregatedHours[date] += hours
  })

  const labels = Array.from({ length: 7 }).map((_, i) => {
    const date = new Date(start)
    date.setDate(date.getDate() + i)
    return date.toISOString().split('T')[0]
  })

  const hoursWorked = labels.map((label) => aggregatedHours[label] || 0)

  barChartData.value = {
    labels: labels,
    datasets: [{ data: hoursWorked, label: 'Hours Worked', backgroundColor: 'blue' }]
  }
}

const previousWeek = () => {
  currentDate.setDate(currentDate.getDate() - 7)
  fetchWeekData(currentDate)
}

const nextWeek = () => {
  currentDate.setDate(currentDate.getDate() + 7)
  fetchWeekData(currentDate)
}

onMounted(() => {
  fetchWeekData(currentDate)
})
</script>
