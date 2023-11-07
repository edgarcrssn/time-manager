<template>
  <section class="text-center">
    <h2>Work Tracking</h2>
    <p v-if="loading">
      Loading...
    </p>
    <p v-else-if="processing">
      Processing...
    </p>
    <p v-else>
      {{ clockIn ? 'Work started at: ' + startDateTime + ' 🧠' : 'Rest 😴' }}
    </p>
    <button :disabled="loading || processing" class="main" @click="clock">
      {{ loading ? 'Loading...' : processing ? 'Processing...' : clockIn ? 'Clock Out' : 'Clock In' }}
    </button>

    <!-- TODO Display only if current user role is manager -->
    <ClockManagerForTeamManager :user-id="+userId" />
  </section>
</template>

<script lang="ts" setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue'
import { apiUrl } from '../constants/urls'
import ClockManagerForTeamManager from './ClockManagerForTeamManager.vue'
import { fetchData } from '../services/httpService'

const { userId } = defineProps({
  userId: {
    type: Number,
    required: true
  }
})

const startDateTime = ref<string | null>(null)
const clockIn = ref<boolean | null>(null)
const API_URL = `${apiUrl}/api/clocks/${userId}`

const loading = ref(true)
const processing = ref(false)

const refresh = async () => {
  if (processing.value) return

  try {
    const data = await fetchData(`${API_URL}/last`)
    if (data && data?.clock) {
      const lastClock = data.clock
      clockIn.value = lastClock.status
      startDateTime.value = lastClock.status ? new Date(lastClock.time).toLocaleString() : null
    }
  } catch (error) {
    console.error('Error fetching clock status:', error)
  } finally {
    loading.value = false
  }
}

let intervalId: ReturnType<typeof setInterval>

onMounted(() => {
  refresh()
  intervalId = setInterval(refresh, 10000)
})

onUnmounted(() => {
  clearInterval(intervalId)
})

const clock = async () => {
  processing.value = true
  try {
    const currentTime = new Date().toISOString()
    const data = await fetchData(API_URL, 'POST', {
      clock: {
        time: currentTime
      }
    })

    const lastClock = data.newClock
    clockIn.value = lastClock.status

    if (lastClock.status) {
      startDateTime.value = new Date(lastClock.time).toLocaleString()
    } else if (data.length > 1) {
      const previousClock = data[data.length - 2]
      await createWorkingTime(previousClock.time, lastClock.time)
      startDateTime.value = null
    }
  } catch (error) {
    console.error('Error clocking in/out:', error)
  } finally {
    processing.value = false
  }
}

const createWorkingTime = async (startTime: string, endTime: string) => {
  const workingTimesAPI = `${apiUrl}/api/workingtimes/${userId}`
  try {
    await fetchData(workingTimesAPI, 'POST', {
      workingtime: {
        start: startTime,
        end: endTime
      }
    })
  } catch (error) {
    console.error('Error creating working time:', error)
  }
}
</script>
