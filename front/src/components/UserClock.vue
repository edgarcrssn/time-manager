<template>
  <div v-if="tiny" class="flex flex-row items-center gap-2">
    <button :disabled="loading || processing" class="main m-0 block w-full" @click="clock">
      {{ clockIn ? '🧠 ' + timeSinceLastClockIn : '😴 Rest' }}
    </button>
  </div>
  <div v-else class="flex flex-col items-center gap-1">
    <p v-if="loading">
      Loading...
    </p>
    <p v-else-if="processing">
      Processing...
    </p>
    <p v-else>
      {{ clockIn ? '🧠 Since: ' + timeSinceLastClockIn : '😴 Rest' }}
    </p>
    <button :disabled="loading || processing" class="main m-0" @click="clock">
      {{ loading ? 'Loading...' : processing ? 'Processing...' : clockIn ? 'Clock Out' : 'Clock In' }}
    </button>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'
import { getTimeElapsedSinceDate } from '../helpers/dateUtils'

const { userId, tiny, onClock } = defineProps({
  userId: {
    type: Number,
    required: true
  },
  tiny: {
    type: Boolean,
    required: false,
    default: false
  },
  onClock: {
    type: Function,
    default: () => {},
    required: false
  }
})

const clockIn = ref<boolean | null>(null)
const timeSinceLastClockIn = ref<string>('0')

const loading = ref(true)
const processing = ref(false)

let timer: ReturnType<typeof setInterval>

onMounted(() => {
  getLastClock()
})

onUnmounted(() => {
  clearInterval(timer)
})

const getLastClock = async () => {
  if (processing.value) return

  try {
    const data = await fetchData(`${apiUrl}/api/clocks/${userId}/last`)
    if (data && data?.clock) {
      const lastClock = data.clock
      clockIn.value = lastClock.status

      if (lastClock.status) {
        timeSinceLastClockIn.value = getTimeElapsedSinceDate(lastClock.time)
        timer = setInterval(() => {
          timeSinceLastClockIn.value = getTimeElapsedSinceDate(lastClock.time)
        }, 1000)
      } else {
        clearInterval(timer)
        timeSinceLastClockIn.value = '0'
      }
    }
  } catch (error) {
    console.error('Error fetching clock status:', error)
  } finally {
    loading.value = false
  }
}

const clock = async () => {
  processing.value = true
  try {
    const currentTime = new Date().toISOString()
    const data = await fetchData(`${apiUrl}/api/clocks/${userId}`, 'POST', {
      clock: {
        time: currentTime
      }
    })

    const lastClock = data.newClock
    clockIn.value = lastClock.status

    if (lastClock.status) {
      timeSinceLastClockIn.value = getTimeElapsedSinceDate(lastClock.time)
      timer = setInterval(() => {
        timeSinceLastClockIn.value = getTimeElapsedSinceDate(lastClock.time)
      }, 1000)
    } else {
      clearInterval(timer)
      timeSinceLastClockIn.value = '0'
    }

    createToast(
      { title: "You have clock'in with success" },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
  } catch (error) {
    createToast(
      { title: "An error occurred while the clock'in operation" },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error clocking in/out:', error)
  } finally {
    processing.value = false
    onClock()
  }
}
</script>
