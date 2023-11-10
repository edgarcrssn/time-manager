<template>
  <section class="p-4 flex flex-col items-center justify-center text-center w-[500px]">
    <h2>Login</h2>
    <form class="w-full" @submit.prevent="submitLogin">
      <div>
        <input id="username" v-model="credentials.username" placeholder="Username" type="text" required>
      </div>
      <div>
        <input id="password" v-model="credentials.password" placeholder="Password" type="password" required>
      </div>
      <button type="submit" class="main">
        Login
      </button>
      <router-link to="/faq">
        <button class="main">
          Read FAQ
        </button>
      </router-link>
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
