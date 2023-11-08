<template>
  <section class="p-2 flex flex-col items-center">
    <h2>Register</h2>
    <form class="w-full max-w-md" @submit.prevent="submitRegister">
      <div>
        <label for="username">Username:</label>
        <input id="username" v-model="newUser.username" type="text" required>
      </div>
      <div>
        <label for="email">Email:</label>
        <input id="email" v-model="newUser.email" type="email" required>
      </div>
      <div>
        <label for="password">Password:</label>
        <input id="password" v-model="newUser.password" type="password" required>
      </div>
      <div>
        <label for="role">Role:</label>
        <select id="role" v-model="newUser.role" required>
          <option value="employee">
            Employee
          </option>
          <option value="manager">
            Manager
          </option>
        </select>
      </div>
      <button type="submit" class="main">
        Register
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

const newUser = ref({
  username: '',
  email: '',
  password: '',
  role: 'employee'
})

const router = useRouter()

const submitRegister = async () => {
  const API_URL = `${apiUrl}/register`

  try {
    const data = await fetchData(API_URL, 'POST', { user: newUser.value })

    const { csrf_token, user } = data

    sessionStorage.setItem('csrf_token', csrf_token)
    sessionStorage.setItem('userID', user.id.toString())
    sessionStorage.setItem('userRole', user.role)
    createToast(
      { title: 'Your account has been created with success' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    router.push(`/dashboard/${user.id}`)
  } catch (error) {
    createToast(
      { title: 'An error occurred while the creation of the account' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Registration error:', error)
  }
}
</script>
