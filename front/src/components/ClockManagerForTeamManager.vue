<template>
  <section class="text-center">
    <h2>My team(s) Work Tracking</h2>
    <div v-if="!loading">
      <ul v-if="ownedTeams?.length">
        <li v-for="team in ownedTeams" :key="team.id">
          <TeamClocks :user-id="userId" :team="team" />
        </li>
      </ul>
      <p v-else>
        You have no team.
      </p>
    </div>
  </section>
</template>

<script lang="ts" setup>
import TeamClocks from './TeamClocks.vue'
import { onMounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { Team } from '../models/Teams'
import { fetchData } from '../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'

const { userId } = defineProps({
  userId: {
    type: Number || String,
    required: true
  }
})

const ownedTeams = ref<Team[] | null>(null)

const loading = ref(true)

const getTeams = async () => {
  try {
    const API_URL = `${apiUrl}/api/teams/owned/${userId}`
    const data = await fetchData(API_URL)
    if (data?.teams) ownedTeams.value = data.teams
  } catch (error) {
    createToast(
      { title: "An error occured while the clock'in/out operation" },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error fetching owned teams:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  getTeams()
})
</script>
