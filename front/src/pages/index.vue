<template>
  <div class="flex flex-wrap min-h-screen items-stretch relative overflow-hidden">
    <div class="flex flex-col justify-center items-center w-full lg:w-[55%] p-4">
      <img
        alt="logo"
        src="../assets/images/earth.png"
        class="absolute -left-[120px] -top-[50px] max-h-[250px] w-auto z-50"
      >
      <div class="w-1/2">
        <h1 class="text-6xl md:text-8xl font-bold text-customPurple mb-4">
          Epic Hourly
        </h1>
        <p class="text-xl md:text-3xl">
          The easy-to-use time manager for your business.
        </p>
        <Login />
      </div>
    </div>

    <div class="w-full lg:w-[45%]">
      <img
        alt="logo"
        src="../assets/images/saturn.png"
        class="absolute -right-[150px] -top-[20px] w-[40%] max-h-[500px] max-w-[700px] z-50"
      >
      <img
        alt="logo"
        src="../assets/images/logo.png"
        class="absolute lg:top-1/2 lg:left-2/3 lg:transform lg:-translate-x-1/2 lg:-translate-y-1/2 h-1/2 object-cover z-10"
      >
      <img alt="background" src="../assets/images/background.jpg" class="h-full w-full object-cover">
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
