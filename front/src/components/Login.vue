<template>
  <section class="flex flex-col w-full">
    <h2>Login</h2>
    <form class="flex flex-col w-full max-w-[350px]" @submit.prevent="submitLogin">
      <input
        id="username"
        v-model="credentials.username"
        class="border rounded-md p-2 mb-3 w-full z-50"
        placeholder="Username"
        type="text"
        required
      >
      <input
        id="password"
        v-model="credentials.password"
        class="border rounded-md p-2 w-full z-50"
        placeholder="Password"
        type="password"
        required
      >
      <div class="flex flex-row-reverse gap-2 z-50">
        <button type="submit" class="main">
          <img alt="right" src="../assets/right.svg" class="w-5 h-5">
        </button>
        <router-link to="/faq">
          <button class="main">
            Read FAQ
          </button>
        </router-link>
      </div>
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
      { title: 'An error occurred while the login of the user' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Login error:', error)
  }
}
</script>
