<template>
  <section>
    <h3>{{ team.name }}</h3>
    <p v-if="loading">
      Loading...
    </p>
    <p v-else-if="processing">
      Processing...
    </p>
    <div v-else>
      <ul v-if="teamMembers?.length">
        <li v-for="member in teamMembers" :key="member.id">
          <UserClock v-if="member.id != +userId" :member="member" />
        </li>
      </ul>
      <p v-else>
        There is no member in this team.
      </p>
    </div>
    <button :disabled="loading || processing" @click="clockForAllTeamMembers">
      Toggle clock for all team members
    </button>
  </section>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { Team } from '../models/Teams'
import { User } from '../models/Users'
import UserClock from './UserClock.vue'
import { fetchData } from '../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'

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

const getTeamUsers = async () => {
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

onMounted(() => {
  getTeamUsers()
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
    createToast(
      { title: "You have clock'in for your teammates with success" },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    console.log(data)
  } catch (error) {
    createToast(
      { title: "An error occured while the operation to clock'in for your teammates" },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error(error)
  } finally {
    processing.value = false
    getTeamUsers()
  }
}
</script>
