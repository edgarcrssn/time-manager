<template>
  <div>
    {{ member.username }}
    <p v-if="!loading && !processing">
      {{ clockIn ? 'Work started at: ' + startDateTime + ' 🧠' : 'Rest 😴' }}
    </p>
    <button v-if="!loading && !processing" class="main" @click="clock">
      {{ clockIn ? 'Clock Out' : 'Clock In' }}
    </button>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { User } from '../models/Users'

const { member } = defineProps({
  member: {
    type: Object as () => Omit<User, 'team'>,
    required: true
  }
  // refresh: {
  //   type: Function as () => Promise<void>,
  //   required: false,
  //   default: () => {}
  // }
})

const startDateTime = ref<string | null>(null)
const clockIn = ref<boolean | null>(null)

const loading = ref(true)
const processing = ref(false)

onMounted(() => {
  getLastClocks()
})

const getLastClocks = async () => {
  try {
    const response = await fetch(`${apiUrl}/api/clocks/${member.id}`)
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

const clock = async () => {
  try {
    const currentTime = new Date().toISOString()
    const response = await fetch(`${apiUrl}/api/clocks/${member.id}`, {
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
    const data = await response.json()
    console.log(data)
  } catch (error) {
    console.error(error)
  } finally {
    // refresh()
  }
}
</script>
