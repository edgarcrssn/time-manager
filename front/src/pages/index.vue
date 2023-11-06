<template>
  <div class="auth-container">
    <div class="auth-switch flex justify-center gap-2">
      <button :class="{ main: currentView === 'login' }" @click="toggleView('login')">
        Login
      </button>
      <button :class="{ main: currentView === 'register' }" @click="toggleView('register')">
        Register
      </button>
    </div>

    <Login v-if="currentView === 'login'" />
    <Register v-else />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Login from '../components/Login.vue'
import Register from '../components/Register.vue'

const currentView = ref('login')
const storedUserID = sessionStorage.getItem('userID')
const router = useRouter()

const toggleView = (view: string) => {
  currentView.value = view
}

onMounted(() => {
  if (storedUserID) {
    router.push(`/dashboard/${storedUserID}`)
  }
})
</script>

<style scoped></style>