<script lang="ts">
import { ref, onMounted, onBeforeMount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import WorkingTime from '../components/WorkingTime.vue'

export default {
  name: 'WorkingTimePage',
  components: { WorkingTime },
  setup () {
    const route = useRoute()
    const router = useRouter()

    const routeParamUserId = route.params.userId
    console.log(routeParamUserId)

    const storedUserID = localStorage.getItem('userID') ? Number(localStorage.getItem('userID')) : null
    const storedUserRole = localStorage.getItem('userRole')

    const workingTimes = ref([{
      id: 1,
      start: '08:00 AM',
      end: '04:00 PM',
      userId: 123
    }])

    onBeforeMount(() => {
      if (!storedUserID) {
        router.push('/')
      }
      if ((+routeParamUserId !== storedUserID) && (storedUserRole !== 'general_manager')) {
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
      workingTimes
    }
  }
}
</script>

<template>
  <div class="p-2 flex flex-col items-center">
    <h1 class="text-3xl font-bold underline">
      Working time
    </h1>
    <ul class="w-full max-w-md">
      <li
        v-for="workingTime in workingTimes"
        :key="workingTime.id"
      >
        <WorkingTime :working-time="workingTime" />
      </li>
    </ul>
  </div>
</template>
