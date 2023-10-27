<template>
  <div class="login-container">
    <h1>Login</h1>
    <form @submit.prevent="login">
      <input
        v-model="email"
        type="email"
        placeholder="Enter your email"
      >
      <button type="submit">
        Login
      </button>
    </form>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const email = ref('')
const router = useRouter()

const checkStoredUserID = () => {
  const storedUserID = localStorage.getItem('userID')
  if (storedUserID) {
    router.push(`/dashboard/${storedUserID}`)
  }
}

const login = async () => {
  try {
    const API_URL = `${import.meta.env.VITE_API_URL}/api/users`
    const response = await fetch(API_URL + '?email=' + email.value)
    const users = await response.json()

    if (users && users.length > 0) {
      const userID = users[0].id
      const userRole = users[0].role
      localStorage.setItem('userID', userID.toString())
      localStorage.setItem('userRole', userRole.toString())
      router.push(`/dashboard/${userID}`)
    } else {
      console.error('No user found for this email')
    }
  } catch (error) {
    console.error('Error fetching user by email:', error)
  }
}

onMounted(() => {
  checkStoredUserID()
})
</script>
