<template>
  <div class="p-2 flex flex-col items-center">
    <h2 class="text-3xl">
      Profile
    </h2>
    <div class="w-full max-w-md">
      <div><strong>Username:</strong> {{ user.username }}</div>
      <div><strong>Email:</strong> {{ user.email }}</div>
      <div><strong>Role:</strong> {{ user.role }}</div>
      <div v-if="user.team">
        <strong>Team:</strong> {{ user.team.name }}
      </div>
      <button
        v-if="canDelete"
        class="bg-red-600 text-white px-4 py-2 mt-4"
        @click="deleteAccount"
      >
        Delete Account
      </button>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, onBeforeMount } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const user = ref({})

const storedUserID = localStorage.getItem('userID') ? Number(localStorage.getItem('userID')) : null
const storedUserRole = localStorage.getItem('userRole')

onBeforeMount(() => {
  if (!storedUserID) {
    router.push('/')
  }
})

const fetchProfile = async () => {
  const userId = route.params.userId
  const API_URL = `${import.meta.env.VITE_API_URL}/api/users/${userId}`
  try {
    const response = await fetch(API_URL)
    if (!response.ok) {
      if (response.status === 404) {
        router.push(`/profile/${storedUserID}`)
        return
      }
      throw new Error('Failed to fetch profile')
    }
    user.value = await response.json()
  } catch (error) {
    console.error('Error fetching profile:', error)
  }
}

const deleteAccount = async () => {
  if (storedUserRole === 'general_manager' || storedUserID === user.value.id) {
    const API_URL = `${import.meta.env.VITE_API_URL}/api/users/${user.value.id}`
    try {
      const response = await fetch(API_URL, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json'
        }
      })

      if (!response.ok) {
        throw new Error('Failed to delete the profile')
      }

      if (storedUserID === user.value.id) {
        localStorage.removeItem('userID')
        localStorage.removeItem('userRole')
        router.push('/')
      } else {
        router.push(`/dashboard/${storedUserID}`)
      }
    } catch (error) {
      console.error('Error deleting profile:', error)
    }
  }
}

const canDelete = computed(() => {
  return storedUserRole === 'general_manager' || storedUserID === user.value.id
})

onMounted(() => {
  fetchProfile()
})
</script>
