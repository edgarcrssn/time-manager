<template>
  <section class="p-2 flex flex-col items-center">
    <h2>Register</h2>
    <form @submit.prevent="submitRegister" class="w-full max-w-md">
      <div>
        <label for="username">Username:</label>
        <input v-model="newUser.username" type="text" id="username" required>
      </div>
      <div>
        <label for="email">Email:</label>
        <input v-model="newUser.email" type="email" id="email" required>
      </div>
      <div>
        <label for="password">Password:</label>
        <input v-model="newUser.password" type="password" id="password" required>
      </div>
      <div>
        <label for="role">Role:</label>
        <select v-model="newUser.role" id="role" required>
          <option value="employee">Employee</option>
          <option value="manager">Manager</option>
        </select>
      </div>
      <button type="submit" class="main">Register</button>
    </form>
  </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

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
    const data = await fetchData(API_URL, 'POST', { user: newUser.value });

    const { csrf_token, user } = data;

    sessionStorage.setItem('csrf_token', csrf_token);
    sessionStorage.setItem('userID', user.id.toString());
    sessionStorage.setItem('userRole', user.role);

    router.push(`/dashboard/${user.id}`);
  } catch (error) {
    console.error('Registration error:', error);
  }
}
</script>