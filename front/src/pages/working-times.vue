<template>
  <section class="p-2 flex flex-col items-center">
    <h1 class="text-3xl font-bold underline">Working times</h1>
    <article class="w-full max-w-md">
      {{ workingTimes }}
    </article>
  </section>
</template>

<script lang="ts" setup>
import { ref, onMounted, onBeforeMount } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

const routeParamUserId = route.params.userId

const storedUserID = localStorage.getItem('userID') ? Number(localStorage.getItem('userID')) : null
const storedUserRole = localStorage.getItem('userRole')

const workingTimes = ref([
  {
    id: 1,
    start: '08:00 AM',
    end: '04:00 PM',
    userId: 123
  }
])

onBeforeMount(() => {
  if (!storedUserID) {
    router.push('/')
  }
  if (+routeParamUserId !== storedUserID && storedUserRole !== 'general_manager') {
    router.push(`/dashboard/${storedUserID}`)
  }
})

const getWorkingTimes = async () => {
  const API_URL = `${import.meta.env.VITE_API_URL}/api/workingtimes/${routeParamUserId}`
  try {
    const response = await fetch(API_URL)
    if (!response.ok) {
      if (response.status === 404) {
        router.push(`/dashboard/${storedUserID}`)
        return
      }
      throw new Error('Failed to fetch working times')
    }
    const data = await response.json()
    workingTimes.value = data
  } catch (error) {
    console.error('Error fetching working times:', error)
  }
}

onMounted(() => {
  getWorkingTimes()
})
</script>