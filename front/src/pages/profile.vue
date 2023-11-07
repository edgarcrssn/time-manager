<template>
  <section class="p-2 flex flex-col items-center">
    <h2>Profile</h2>
    <article class="w-full max-w-md">
      <div><strong>Username:</strong> {{ user.username }}</div>
      <div><strong>Email:</strong> {{ user.email }}</div>
      <div><strong>Role:</strong> {{ user.role }}</div>
      <div v-if="user.team">
        <strong>Team:</strong> {{ user.team.name }}
      </div>
      <button v-if="canDelete" class="bg-error text-white px-4 py-2 mt-4" @click="deleteAccount">
        Delete Account
      </button>
    </article>
  </section>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, onBeforeMount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { User } from '../models/Users'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

const route = useRoute()
const router = useRouter()
const user = ref<Partial<User>>({})

const storedUserID = sessionStorage.getItem('userID') ? Number(sessionStorage.getItem('userID')) : null
const storedUserRole = sessionStorage.getItem('userRole')

onBeforeMount(() => {
  if (!storedUserID) {
    router.push('/')
  }
})

const fetchProfile = async () => {
  const userId = route.params.userId
  const API_URL = `${apiUrl}/api/users/${userId}`
  try {
    user.value = await fetchData(API_URL)
  } catch (error: unknown) {
    if (error instanceof Error && error.message.includes('404')) {
      router.push(`/profile/${storedUserID}`)
    } else {
      console.error('Error fetching profile:', error)
    }
  }
}

const deleteAccount = async () => {
  if (storedUserRole === 'general_manager' || storedUserID === user.value.id) {
    const API_URL = `${apiUrl}/api/users/${user.value.id}`
    try {
      await fetchData(API_URL, 'DELETE')

      if (storedUserID === user.value.id) {
        await fetchData(apiUrl + '/logout', 'POST')
        sessionStorage.removeItem('userID')
        sessionStorage.removeItem('userRole')
        sessionStorage.removeItem('csrf_token')
        router.push('/')
      } else {
        router.push(`/dashboard/${storedUserID}`)
      }
    } catch (error: unknown) {
      if (error instanceof Error) {
        console.error('Error deleting profile:', error)
      }
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