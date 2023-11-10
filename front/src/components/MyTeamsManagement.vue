<template>
  <div>
    <section v-if="['manager', 'general_manager'].includes(myRole || '')" class="bg-white border rounded-3xl p-4 mb-6">
      <h3 class="text-center">
        Create a team
      </h3>
      <CreateTeamForm :on-create="fetchMyTeams" />
    </section>

    <section class="bg-white border rounded-3xl p-4 mb-6">
      <h3 class="text-center">
        My team{{ myTeams.length > 1 ? 's' : '' }}
      </h3>
      <p v-if="myTeamsAreLoading">
        Loading...
      </p>
      <TeamTable
        v-for="team in myTeams"
        v-else-if="myTeams.length"
        :key="team.id"
        :team="team"
        :on-clock="refreshUserClocks"
        :refresh="refresh"
        :fetch-my-teams="fetchMyTeams"
      />
      <p v-else>
        You have no team.
      </p>
    </section>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import CreateTeamForm from './forms/CreateTeamForm.vue'
import TeamTable from './TeamTable.vue'
import { fetchData } from '../services/httpService'
import { apiUrl } from '../constants/urls'
import { Team } from '../models/Teams'

const { myId } = defineProps({
  myId: {
    required: true,
    type: Number
  }
})

const myRole = sessionStorage.getItem('userRole')

const refresh = ref(1)
const refreshUserClocks = () => {
  refresh.value = refresh.value + 1
}

const myTeams = ref<Team[]>([])
const myTeamsAreLoading = ref<boolean>(true)

onMounted(() => {
  fetchMyTeams()
})

const fetchMyTeams = async () => {
  myTeamsAreLoading.value = true
  try {
    const data: { teams: Team[] } | null = await fetchData(`${apiUrl}/api/teams/member/${myId}`)
    myTeams.value = data?.teams ? data.teams : []
  } catch (error) {
    console.error(error)
  } finally {
    myTeamsAreLoading.value = false
  }
}
</script>

<style scoped></style>
