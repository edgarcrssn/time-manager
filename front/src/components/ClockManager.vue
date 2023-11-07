<template>
  <section class="text-center card p-4">
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

    <ClockManagerForTeamManager v-if="['manager', 'general_manager'].includes(currentUserRole)" :user-id="+userId" />
  </section>
</template>

<script lang="ts" setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue'
import { apiUrl } from '../constants/urls'
import ClockManagerForTeamManager from './ClockManagerForTeamManager.vue'
import { fetchData } from '../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'

const { userId } = defineProps({
  userId: {
    type: Number,
    required: true
  }
})

const currentUserRole = ref<string>('')
const startDateTime = ref<string | null>(null)
const clockIn = ref<boolean | null>(null)
const API_URL = `${apiUrl}/api/clocks/${userId}`

const loading = ref(true)
const processing = ref(false)

const getLastClock = async () => {
  if (processing.value) return

  try {
    const data = await fetchData(`${API_URL}/last`)
    if (data && data?.clock) {
      const lastClock = data.clock
      clockIn.value = lastClock.status
      startDateTime.value = lastClock.status ? new Date(lastClock.time).toLocaleString() : null
    }
  } catch (error) {
    createToast(
      { title: 'An error occurred while fetching' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error fetching clock status:', error)
  } finally {
    loading.value = false
  }
}

const showNotificationFunction = () => {
  if (!clockIn.value) {
    createToast(
      { title: "Don't forget to clock'in" },
      { type: 'warning', position: 'bottom-right', transition: 'zoom', timeout: 8000 }
    )
  }
}

let intervalId: ReturnType<typeof setInterval>
onMounted(() => {
  currentUserRole.value = sessionStorage.getItem('userRole') || ''
  getLastClock()
  intervalId = setInterval(getLastClock, 10000)
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
    startDateTime.value = lastClock.status ? new Date(lastClock.time).toLocaleString() : null
    createToast(
      { title: "The clock'in/out operation is a success" },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
  } catch (error) {
    createToast(
      { title: "An error occurred while the clock'in/out operation" },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error clocking in/out:', error)
  } finally {
    processing.value = false
  }
}
</script>
