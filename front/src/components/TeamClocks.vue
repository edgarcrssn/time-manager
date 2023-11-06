<template>
  <section>
    <h3>{{ team.name }}</h3>
    <p v-if="loading">
      Loading...
    </p>
    <p v-else-if="processing">
      Processing...
    </p>
    <ul v-else>
      <li v-for="member in teamMembers" :key="member.id">
        <UserClock v-if="member.id != +userId" :member="member" />
      </li>
    </ul>
    <button :disabled="loading || processing" @click="clockForAllTeamMembers">
      Clock-in for all team members
    </button>
  </section>
</template>

<script lang="ts" setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { Team } from '../models/Teams'
import { User } from '../models/Users'
import UserClock from './UserClock.vue'
import { fetchData } from '../services/httpService'

const { team, userId } = defineProps({
  team: {
    type: Object as () => Team,
    required: true
  },
  userId: {
    type: Number || String,
    required: true
  }
})

const teamMembers = ref<Omit<User, 'team'>[] | null>(null)
const loading = ref(true)

const refresh = async () => {
  try {
    const API_URL = `${apiUrl}/api/teams/${team.id}/users`
    const data = await fetchData(API_URL)
    if (data?.users) teamMembers.value = data.users
  } catch (error) {
    console.error('Error fetching team members:', error)
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

const processing = ref(false)

const clockForAllTeamMembers = async () => {
  processing.value = true
  try {
    const currentTime = new Date().toISOString()
    const data = await fetchData(`${apiUrl}/api/clocks/team/${team.id}`, 'POST', {
      clock: {
        time: currentTime
      }
    })
    console.log(data)
  } catch (error) {
    console.error(error)
  } finally {
    processing.value = false
    refresh()
  }
}
</script>
