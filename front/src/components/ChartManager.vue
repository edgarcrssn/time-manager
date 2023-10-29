<template>
  <section>
    <h2 class="text-3xl mt-4 mb-4">
      User {{ userId }}'s Charts
    </h2>

    <div v-if="viewMode === 'week'">
      <button @click="previousWeek">
        Previous Week
      </button>
      <button @click="nextWeek">
        Next Week
      </button>
    </div>
    <div v-if="viewMode === 'day'">
      <button @click="previousDay">
        Previous Day
      </button>
      <button @click="nextDay">
        Next Day
      </button>
    </div>
    <div v-if="viewMode === 'month'">
      <button @click="previousMonth">
        Previous Month
      </button>
      <button @click="nextMonth">
        Next Month
      </button>
    </div>

    <select
      v-model="viewMode"
      @change="changeViewMode"
    >
      <option value="day">
        Daily View
      </option>
      <option value="week">
        Weekly View
      </option>
      <option value="month">
        Monthly View
      </option>
    </select>

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

const barChartData = ref({
  labels: [],
  datasets: [{ data: [], label: 'Hours Worked', backgroundColor: 'blue' }]
})

const chartOptions = ref({
  responsive: true,
  maintainAspectRatio: false
})

const { userId } = defineProps(['userId'])
const API_URL = `${import.meta.env.VITE_API_URL}/api/workingtimes/${userId}`
const currentDate = new Date()
const viewMode = ref('week')

const changeViewMode = () => {
  switch (viewMode.value) {
    case 'day':
      fetchDayData(currentDate)
      break
    case 'week':
      fetchWeekData(currentDate)
      break
    case 'month':
      fetchMonthData(currentDate)
      break
  }
}

// FETCH DATA
const fetchDayData = async (date) => {
  const response = await fetch(API_URL)
  const data = await response.json()

  const dayData = data.filter((item) => {
    return new Date(item.start).toISOString().split('T')[0] === date.toISOString().split('T')[0]
  })

  const aggregatedHours = {}

  dayData.forEach((item) => {
    const start = new Date(item.start)
    const end = new Date(item.end)
    const hours = (end - start) / (1000 * 60 * 60)
    const date = start.toISOString().split('T')[0]

    if (!aggregatedHours[date]) {
      aggregatedHours[date] = 0
    }
    aggregatedHours[date] += hours
  })

  barChartData.value = {
    labels: [date.toISOString().split('T')[0]],
    datasets: [
      {
        data: [aggregatedHours[date.toISOString().split('T')[0]] || 0],
        label: 'Hours Worked',
        backgroundColor: 'blue'
      }
    ]
  }
}

const fetchWeekData = async (date) => {
  const monday =
    date.getDay() === 0
      ? new Date(date.setDate(date.getDate() - 6))
      : new Date(date.setDate(date.getDate() - date.getDay() + 1))
  const sunday = new Date(date.setDate(date.getDate() + 6))

  const start = monday
  const end = sunday

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

const fetchMonthData = async (date) => {
  const startOfMonth = new Date(date.getFullYear(), date.getMonth(), 1)
  const endOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0)

  const response = await fetch(API_URL)
  const data = await response.json()

  const monthData = data.filter((item) => {
    const startDate = new Date(item.start).toISOString().split('T')[0]
    return startDate >= startOfMonth.toISOString().split('T')[0] && startDate <= endOfMonth.toISOString().split('T')[0]
  })

  const aggregatedHours = {}

  monthData.forEach((item) => {
    const start = new Date(item.start)
    const end = new Date(item.end)
    const hours = (end - start) / (1000 * 60 * 60)
    const date = start.toISOString().split('T')[0]

    if (!aggregatedHours[date]) {
      aggregatedHours[date] = 0
    }
    aggregatedHours[date] += hours
  })

  const daysInMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()

  const labels = Array.from({ length: daysInMonth }).map((_, i) => {
    const dateObj = new Date(startOfMonth)
    dateObj.setDate(dateObj.getDate() + i)
    return dateObj.toISOString().split('T')[0]
  })

  const hoursWorked = labels.map((label) => aggregatedHours[label] || 0)

  barChartData.value = {
    labels: labels,
    datasets: [{ data: hoursWorked, label: 'Hours Worked', backgroundColor: 'blue' }]
  }
}

// NEXT AND PREVIOUS BUTTONS
const previousDay = () => {
  currentDate.setDate(currentDate.getDate() - 1)
  fetchDayData(currentDate)
}

const nextDay = () => {
  currentDate.setDate(currentDate.getDate() + 1)
  fetchDayData(currentDate)
}

const previousWeek = () => {
  currentDate.setDate(currentDate.getDate() - 7)
  fetchWeekData(currentDate)
}

const nextWeek = () => {
  currentDate.setDate(currentDate.getDate() + 7)
  fetchWeekData(currentDate)
}

const previousMonth = () => {
  currentDate.setMonth(currentDate.getMonth() - 1)
  fetchMonthData(currentDate)
}

const nextMonth = () => {
  currentDate.setMonth(currentDate.getMonth() + 1)
  fetchMonthData(currentDate)
}

onMounted(() => {
  fetchWeekData(currentDate)
})
</script>
