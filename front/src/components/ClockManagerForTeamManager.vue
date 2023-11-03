<template>
  <section class="text-center">
    <h2>My team(s) Work Tracking</h2>
    <ul v-if="!loading">
      <li v-for="team in ownedTeams" :key="team.id">
        <TeamClocks :team="team" />
      </li>
    </ul>
  </section>
</template>

<script lang="ts" setup>
import TeamClocks from './TeamClocks.vue'
import { onMounted, onUnmounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { Team } from '../models/Teams'

const { userId } = defineProps(['userId'])

const ownedTeams = ref<Team[] | null>(null)

const loading = ref(true)

const refresh = async () => {
  try {
    const API_URL = `${apiUrl}/api/teams/owned/${userId}`
    const response = await fetch(API_URL)
    const data = await response.json()
    if (data?.teams) ownedTeams.value = data.teams
  } catch (error) {
    console.error('Error fetching owned teams:', error)
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
</script>
