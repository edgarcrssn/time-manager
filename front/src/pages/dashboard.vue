<template>
  <div class="p-2 flex flex-col items-center">
    <ClockManager :key="userId" :user-id="+userId" />
    <ChartManager :key="userId" :user-id="+userId" />
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, watch, Ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import ClockManager from '../components/ClockManager.vue'
import ChartManager from '../components/ChartManager.vue'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

const route = useRoute()
const router = useRouter()
const userId = ref(route.params.userId) as Ref<string>
const username = ref('')

const getUserInfo = async () => {
  try {
    const storedUserID = sessionStorage.getItem('userID')

    if (!storedUserID) {
      router.push('/')
      return
    }

    const API_URL_CURRENT_USER = `${apiUrl}/api/users/${storedUserID}`
    const currentUser = await fetchData(API_URL_CURRENT_USER)
    const API_URL = `${apiUrl}/api/users/${userId.value}`
    const user = await fetchData(API_URL)

    if (user && currentUser) {
      username.value = user.username

      if (currentUser.role === 'employee' && userId.value !== storedUserID) {
        router.push(`/dashboard/${storedUserID}`)
        return
      }

      if (currentUser.role === 'manager' && currentUser.team?.id !== user.team?.id) {
        router.push(`/dashboard/${storedUserID}`)
        return
      }
    } else {
      console.error('No user found for this ID')
    }
  } catch (error) {
    console.error('Error fetching user by ID:', error)
  }
}

watch(
  () => route.params.userId,
  (newUserId) => {
    userId.value = newUserId as string
    getUserInfo()
  }
)

onMounted(() => {
  getUserInfo()
})
</script>
