<template>
  <div class="flex flex-wrap min-h-screen items-stretch">
    <div class="flex justify-center items-center w-full lg:w-1/2">
      <Login />
    </div>

    <div class="relative w-full lg:w-1/2">
      <img
        alt="background"
        src="../assets/images/analytics.jpg"
        class="absolute inset-0 h-full w-full object-cover blur-sm"
      >
      <div class="relative z-10 text-center flex flex-col justify-center items-center h-full text-white p-4">
        <h1 class="text-8xl font-bold mb-4">
          Welcome!
        </h1>
        <p class="mb-1 text-3xl">
          Welcome to EpicHourly, the best time manager
        </p>
        <p class="mb-1 text-3xl">
          New here? Visit our FAQ.
        </p>
        <router-link to="/faq">
          <button class="main">
            Read FAQ
          </button>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Login from '../components/Login.vue'

const storedUserID = sessionStorage.getItem('userID')
const router = useRouter()

onMounted(() => {
  if (storedUserID) {
    router.push(`/dashboard/${storedUserID}`)
  }
})
</script>

<style scoped></style>
