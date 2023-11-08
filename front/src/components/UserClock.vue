<template>
  <div>
    {{ member.username }}
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
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { User } from '../models/Users'
import { fetchData } from '../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'

const { member } = defineProps({
  member: {
    type: Object as () => Omit<User, 'team'>,
    required: true
  }
})

const startDateTime = ref<string | null>(null)
const clockIn = ref<boolean | null>(null)

const loading = ref(true)
const processing = ref(false)

const getLastClock = async () => {
  if (processing.value) return

  try {
    const data = await fetchData(`${apiUrl}/api/clocks/${member.id}/last`)
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

onMounted(() => {
  getLastClock()
})

const clock = async () => {
  processing.value = true
  try {
    const currentTime = new Date().toISOString()
    const data = await fetchData(`${apiUrl}/api/clocks/${member.id}`, 'POST', {
      clock: {
        time: currentTime
      }
    })

    const lastClock = data.newClock
    clockIn.value = lastClock.status
    startDateTime.value = lastClock.status ? new Date(lastClock.time).toLocaleString() : null
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
  }
}
</script>
