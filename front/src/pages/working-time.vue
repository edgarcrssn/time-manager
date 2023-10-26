<script lang="ts">
import { ref, onMounted, onBeforeMount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import WorkingTime from '../components/WorkingTime.vue'
import BarChart from '../components/charts/BarChart.vue'

export default {
  name: 'WorkingTimePage',
  components: { WorkingTime, BarChart },
  setup() {
    const route = useRoute()
    const router = useRouter()

    const routeParamUserId = route.params.userId
    console.log(routeParamUserId)

    const storedUserID = localStorage.getItem('userID') ? Number(localStorage.getItem('userID')) : null
    const storedUserRole = localStorage.getItem('userRole')

    const workingTimes = ref([
      {
        id: 1,
        start: '08:00 AM',
        end: '04:00 PM',
        userId: 123
      }
    ])

    onBeforeMount(() => {
      if (!storedUserID) {
        router.push('/')
      }
      if (+routeParamUserId !== storedUserID && storedUserRole !== 'general_manager') {
        router.push('/dashboard')
      }
    })

    const getWorkingTimes = async () => {
      const API_URL = `${import.meta.env.VITE_API_URL}/api/workingtimes/${routeParamUserId}`
      try {
        const response = await fetch(API_URL)
        if (!response.ok) {
          if (response.status === 404) {
            router.push('/dashboard')
            return
          }
          throw new Error('Failed to fetch profile')
        }
        const data = await response.json()
        console.log(data)
        workingTimes.value = data
      } catch (error) {
        console.error('Error fetching profile:', error)
      }
    }

    onMounted(() => {
      getWorkingTimes()
    })

    return {
      workingTimes,
    }
  },
}
</script>

<template>
  <div class="p-2 flex flex-col items-center">
    <h1 class="text-3xl font-bold underline">Working time</h1>
    <ul class="w-full max-w-md">
      <li v-for="workingTime in workingTimes" :key="workingTime.id">
        <BarChart
          :chart-data="{
            labels: ['j', 'f', 'm', 'a', 'm', 'j', 'j'],
            datasets: [
              {
                label: 'My First Dataset',
                data: [65, 59, 80, 81, 56, 55, 40],
                backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(255, 159, 64, 0.2)',
                  'rgba(255, 205, 86, 0.2)',
                  'rgba(75, 192, 192, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(153, 102, 255, 0.2)',
                  'rgba(201, 203, 207, 0.2)',
                ],
                borderColor: [
                  'rgb(255, 99, 132)',
                  'rgb(255, 159, 64)',
                  'rgb(255, 205, 86)',
                  'rgb(75, 192, 192)',
                  'rgb(54, 162, 235)',
                  'rgb(153, 102, 255)',
                  'rgb(201, 203, 207)',
                ],
                borderWidth: 1,
              },
            ],
          }"
        />
        <WorkingTime :working-time="workingTime" />
      </li>
    </ul>
  </div>
</template>
