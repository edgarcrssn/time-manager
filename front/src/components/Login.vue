<template>
  <section class="p-2 flex flex-col items-center">
    <h2>Login</h2>
    <form @submit.prevent="submitLogin" class="w-full max-w-md">
      <div>
        <label for="username">Username:</label>
        <input v-model="credentials.username" type="text" id="username" required>
      </div>
      <div>
        <label for="password">Password:</label>
        <input v-model="credentials.password" type="password" id="password" required>
      </div>
      <button type="submit" class="main">Login</button>
    </form>
  </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

const credentials = ref({
  username: '',
  password: ''
})

const router = useRouter()

const submitLogin = async () => {
  const API_URL = `${apiUrl}/login`

  try {
    const data = await fetchData(API_URL, 'POST', credentials.value);

    const { csrf_token, user } = data;

    sessionStorage.setItem('csrf_token', csrf_token);
    sessionStorage.setItem('userID', user.id.toString());
    sessionStorage.setItem('userRole', user.role);

    router.push(`/dashboard/${user.id}`);
  } catch (error) {
    console.error('Login error:', error);
  }
}

</script>