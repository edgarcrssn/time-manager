<template>
  <section class="p-2 flex flex-col items-center">
    <h2>Login</h2>
    <form class="w-full max-w-md" @submit.prevent="submitLogin">
      <div>
        <label for="username">Username:</label>
        <input id="username" v-model="credentials.username" type="text" required>
      </div>
      <div>
        <label for="password">Password:</label>
        <input id="password" v-model="credentials.password" type="password" required>
      </div>
      <button type="submit" class="main">
        Login
      </button>
    </form>
  </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'

const credentials = ref({
  username: '',
  password: ''
})

const router = useRouter()

const submitLogin = async () => {
  const API_URL = `${apiUrl}/login`

  try {
    const data = await fetchData(API_URL, 'POST', credentials.value)

    const { csrf_token, user } = data

    sessionStorage.setItem('csrf_token', csrf_token)
    sessionStorage.setItem('userID', user.id.toString())
    sessionStorage.setItem('userRole', user.role)

    router.push(`/dashboard/${user.id}`)
  } catch (error) {
    createToast(
      { title: 'An error occured while the login of the user' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Login error:', error)
  }
}
</script>
