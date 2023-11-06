<template>
  <div class="h-screen flex flex-col">
    <header class="bg-customBlack text-white p-4 flex items-center justify-between">
      <h1 class="text-center flex-grow">
        Dashboard
      </h1>
      <router-link :to="`/dashboard/profile/${storedUserID}`" class="ml-4">
        <img alt="profile" src="../assets/user_icon.svg" class="w-5 h-5">
      </router-link>
    </header>

    <div class="flex flex-row h-full">
      <nav class="bg-customGrey p-4 w-[300px] flex-shrink-0 flex flex-col">
        <ul>
          <li class="mb-2">
            <router-link :to="`/dashboard/${storedUserID}`" class="text-customWhite">
              My Dashboard
            </router-link>
          </li>
          <li class="mb-2">
            <router-link :to="`/dashboard/working-times/${storedUserID}`" class="text-customWhite">
              Working Time
            </router-link>
          </li>
          <li v-if="isManagerOrGeneralManager" class="mb-2">
            <router-link to="/my-team" class="text-customWhite">
              My Team
            </router-link>
          </li>
          <li v-if="isManagerOrGeneralManager" class="mb-2">
            <router-link to="/create-team" class="text-customWhite">
              Create My Team
            </router-link>
          </li>
          <li v-if="isManagerOrGeneralManager" class="mb-2">
            <router-link to="/view-users" class="text-customWhite">
              View Users
            </router-link>
          </li>
        </ul>

        <button class="error text-white px-4 py-2 mt-4 self-end" @click="logout">
          Logout
        </button>
      </nav>

      <main class="flex-grow p-4">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { useRouter } from 'vue-router'
import { computed, onMounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

const router = useRouter()
const storedUserID = ref('')

const logout = async () => {
  try {
    await fetchData(apiUrl + '/logout', 'POST')
    sessionStorage.removeItem('userID')
    sessionStorage.removeItem('userRole')
    sessionStorage.removeItem('csrf_token')

    router.push('/')
  } catch (error) {
    console.error('Error during logout attempt:', error)
  }
}

const isManagerOrGeneralManager = computed(() => {
  const storedUserRole = sessionStorage.getItem('userRole')
  return storedUserRole === 'manager' || storedUserRole === 'general_manager'
})

const getUserInfo = () => {
  const userID = sessionStorage.getItem('userID')
  if (!userID) return
  storedUserID.value = userID
}

onMounted(() => {
  getUserInfo()
})
</script>