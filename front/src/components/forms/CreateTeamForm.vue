<template>
  <div class="mb-4 text-center flex flex-col items-center">
    <form class="w-full flex flex-col items-center" @submit.prevent="createTeam">
      <input
        v-model="teamName"
        placeholder="Team name"
        type="text"
        class="mt-1 p-2 w-1/4 border rounded-md focus:ring focus:ring-indigo-200 focus:border-indigo-500"
      >
      <button type="submit" class="main">
        Create team
      </button>
    </form>
  </div>
</template>

<script lang="ts" setup>
import { ref } from 'vue'
import { apiUrl } from '../../constants/urls'
import { fetchData } from '../../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'

const { onCreate } = defineProps({
  onCreate: {
    type: Function,
    default: () => {},
    required: false
  }
})

const teamName = ref<string>('')
const userId = sessionStorage.getItem('userID')

const createTeam = async () => {
  try {
    const body = {
      team: {
        name: teamName.value
      },
      user_id: userId
    }
    await fetchData(`${apiUrl}/api/teams`, 'POST', body)
    createToast(
      { title: 'The team has been created' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    onCreate()
    teamName.value = ''
  } catch (error) {
    createToast(
      { title: 'An error occurred while the creation of the team' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    console.error('An error occurred while the creation of the team')
  }
}
</script>

<style scoped></style>
