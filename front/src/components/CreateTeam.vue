<template>
  <div class="mb-4 text-center flex flex-col items-center">
    <h2>Create Team</h2>
    <form class="w-full flex flex-col items-center" @submit.prevent="createTeam">
      <label for="input" placeholder="Name" class="block text-sm font-medium text-gray-600">Enter the name of the new team</label>
      <input
        v-model="teamName"
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
import { apiUrl } from '../constants/urls'

const teamName = ref<string>('')
const userId = localStorage.getItem('userID')

const createTeam = async () => {
  try {
    const body = {
      team: {
        name: teamName.value
      },
      user_id: userId
    }
    const requestOptions = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(body)
    }
    await fetch(`${apiUrl}/api/teams`, requestOptions).then((response) => {
      if (!response.ok) {
        throw new Error('An error occured while the creation of the team')
      }
    })
  } catch (error) {
    console.error('An error occured while the creation of the team')
  }
}
</script>

<style scoped></style>
