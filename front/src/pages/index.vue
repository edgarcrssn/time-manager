<template>
  <div class="flex justify-center items-center">
    <Login />
    <img alt="analytics" src="../assets/images/analytics.jpg" class="rounded-3xl w-[500px]">
    <img alt="happy" src="../assets/images/happy.jpg" class="rounded-3xl w-[500px]">
    <img alt="work" src="../assets/images/work.jpg" class="rounded-3xl w-[500px]">
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
