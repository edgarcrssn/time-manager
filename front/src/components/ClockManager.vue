<template>
  <section class="text-center">
    <h2>Work Tracking</h2>
    <p v-if="!loading && !processing">
      {{ clockIn ? 'Work started at: ' + startDateTime + ' 🧠' : 'Rest 😴' }}
    </p>
    <button v-if="!loading && !processing" class="main" @click="clock">
      {{ clockIn ? 'Clock Out' : 'Clock In' }}
    </button>
    <button v-else disabled class="main">
      Processing...
    </button>

    <!-- TODO Display only if current user role is manager -->
    <!-- <ClockManagerForTeamManager :user-id="userId" /> -->
  </section>
</template>

<script lang="ts" setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue'
import { apiUrl } from '../constants/urls'
// import ClockManagerForTeamManager from './ClockManagerForTeamManager.vue'

const { userId } = defineProps(['userId'])

const startDateTime = ref<string | null>(null)
const clockIn = ref<boolean | null>(null)
const API_URL = `${apiUrl}/api/clocks/${userId}`

const loading = ref(true)
const processing = ref(false)

const refresh = async () => {
  try {
    const response = await fetch(API_URL)
    const data = await response.json()
    if (data && data.length > 0) {
      const lastClock = data[data.length - 1]
      clockIn.value = lastClock.status
      startDateTime.value = lastClock.status ? new Date(lastClock.time).toLocaleString() : null
    }
    loading.value = false
  } catch (error) {
    console.error('Error fetching clock status:', error)
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
    await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        clock: {
          time: currentTime
        }
      })
    })

    const response = await fetch(API_URL)
    const data = await response.json()
    const lastClock = data[data.length - 1]
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
    setTimeout(() => {
      processing.value = false
    }, 300)
  }
}

const createWorkingTime = async (startTime: string, endTime: string) => {
  const workingTimesAPI = `${apiUrl}/api/workingtimes/${userId}`
  try {
    await fetch(workingTimesAPI, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        workingtime: {
          start: startTime,
          end: endTime
        }
      })
    })
  } catch (error) {
    console.error('Error creating working time:', error)
  }
}
</script>
