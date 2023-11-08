<template>
  <section class="w-full">
    <h2>User {{ userId }}'s Charts</h2>

    <div v-if="viewMode === 'week'" class="mb-2">
      <button class="main mr-2" @click="previousWeek">
        Previous Week
      </button>
      <button class="main" @click="nextWeek">
        Next Week
      </button>
    </div>
    <div v-if="viewMode === 'day'" class="mb-2">
      <button class="main mr-2" @click="previousDay">
        Previous Day
      </button>
      <button class="main" @click="nextDay">
        Next Day
      </button>
    </div>
    <div v-if="viewMode === 'month'" class="mb-2">
      <button class="main mr-2" @click="previousMonth">
        Previous Month
      </button>
      <button class="main" @click="nextMonth">
        Next Month
      </button>
    </div>

    <select v-model="viewMode" @change="changeViewMode">
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
      <div class="h-[300px]">
        <BarChart :data="barChartData" :options="chartOptions" />
      </div>
      <div>
        <LineChart :data="lineChartData" :options="chartOptions" />
      </div>
      <div v-if="viewMode === 'week'" class="mt-10">
        <PieChart :data="pieChartData" :options="chartOptions" />
      </div>
    </div>
  </section>
</template>

<script lang="ts" setup>
import { ref, onMounted, defineProps } from 'vue'
import BarChart from './charts/BarChart.vue'
import LineChart from './charts/LineChart.vue'
import PieChart from './charts/PieChart.vue'
import { WorkingTime } from '../models/WorkingTimes'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

type ChartData = {
  labels: string[]
  datasets: {
    data: number[]
    label?: string
    backgroundColor?: string | string[]
  }[]
}

const barChartData = ref<ChartData>({
  labels: [],
  datasets: [{ data: [], label: 'Hours Worked' }]
})

const lineChartData = ref<ChartData>({
  labels: [],
  datasets: [{ data: [], label: 'Hours Worked' }]
})

const pieChartData = ref<ChartData>({
  labels: [],
  datasets: [{ data: [] }]
})

const chartOptions = ref<{ responsive: boolean; maintainAspectRatio: boolean }>({
  responsive: true,
  maintainAspectRatio: false
})

const { userId } = defineProps(['userId'])
const API_URL = `${apiUrl}/api/workingtimes/${userId}`
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
const fetchDayData = async (date: Date) => {
  const data: WorkingTime[] = await fetchData(API_URL)

  const dayData = data.filter((item: WorkingTime) => {
    return new Date(item.start).toISOString().split('T')[0] === date.toISOString().split('T')[0]
  })

  const aggregatedHours: { [date: string]: number } = {}

  dayData.forEach((item: WorkingTime) => {
    const start = new Date(item.start)
    const end = new Date(item.end)
    const hours = (+end - +start) / (1000 * 60 * 60)
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
        backgroundColor: '#4A90E2'
      }
    ]
  }

  lineChartData.value = {
    labels: [date.toISOString().split('T')[0]],
    datasets: [
      {
        data: [aggregatedHours[date.toISOString().split('T')[0]] || 0],
        label: 'Hours Worked',
        backgroundColor: '#4A90E2'
      }
    ]
  }
}

const fetchWeekData = async (date: Date) => {
  const monday =
    date.getDay() === 0
      ? new Date(date.setDate(date.getDate() - 6))
      : new Date(date.setDate(date.getDate() - date.getDay() + 1))
  const sunday = new Date(date.setDate(date.getDate() + 6))

  const start = monday
  const end = sunday

  const data: WorkingTime[] = await fetchData(API_URL)

  const weekData = data.filter((item: WorkingTime) => {
    const startDate = new Date(item.start).toISOString().split('T')[0]
    return startDate >= start.toISOString().split('T')[0] && startDate <= end.toISOString().split('T')[0]
  })

  const aggregatedHours: { [date: string]: number } = {}

  weekData.forEach((item: WorkingTime) => {
    const start = new Date(item.start)
    const end = new Date(item.end)
    const hours = (+end - +start) / (1000 * 60 * 60)
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
    datasets: [{ data: hoursWorked, label: 'Hours Worked', backgroundColor: '#4A90E2' }]
  }

  lineChartData.value = {
    labels: labels,
    datasets: [{ data: hoursWorked, label: 'Hours Worked', backgroundColor: '#4A90E2' }]
  }

  pieChartData.value = {
    labels: labels,
    datasets: [
      {
        data: hoursWorked,
        backgroundColor: ['#E94E77', '#F9A825', '#F6E05E', '#4CAF50', '#4A90E2', '#667EEA', '#9D48B9']
      }
    ]
  }
}

const fetchMonthData = async (date: Date) => {
  const startOfMonth = new Date(date.getFullYear(), date.getMonth(), 1)
  const endOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0)

  const data: WorkingTime[] = await fetchData(API_URL)

  const monthData = data.filter((item: WorkingTime) => {
    const startDate = new Date(item.start).toISOString().split('T')[0]
    return startDate >= startOfMonth.toISOString().split('T')[0] && startDate <= endOfMonth.toISOString().split('T')[0]
  })

  const aggregatedHours: { [date: string]: number } = {}

  monthData.forEach((item: WorkingTime) => {
    const start = new Date(item.start)
    const end = new Date(item.end)
    const hours = (+end - +start) / (1000 * 60 * 60)
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
    datasets: [{ data: hoursWorked, label: 'Hours Worked', backgroundColor: '#4A90E2' }]
  }

  lineChartData.value = {
    labels: labels,
    datasets: [{ data: hoursWorked, label: 'Hours Worked', backgroundColor: '#4A90E2' }]
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
