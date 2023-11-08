<template>
  <div class="h-screen flex flex-col">
    <header class="bg-customMain text-white p-4 flex items-center justify-between">
      <div class="flex-1 invisible">
        <img src="../assets/user_icon.svg" class="w-8 h-8 opacity-0">
      </div>
      <h1 class="flex-1 text-center">
        EpicHourly
      </h1>
      <router-link :to="`/dashboard/profile/${storedUserID}`" class="flex-1 flex justify-end">
        <img alt="profile" src="../assets/user_icon.svg" class="w-8 h-8">
      </router-link>
    </header>

    <div class="flex flex-row h-full overflow-hidden">
      <nav class="bg-customSecondary p-4 w-[300px] flex-shrink-0 flex-col hidden sm:flex">
        <ul>
          <li class="mb-2">
            <router-link :to="`/dashboard/${storedUserID}`" class="text-customWhite flex items-center">
              <img alt="dashboard" src="../assets/chart_icon.svg" class="w-8 h-8 mr-2">
              My Dashboard
            </router-link>
          </li>
          <li class="mb-2">
            <router-link :to="`/dashboard/working-times/${storedUserID}`" class="text-customWhite flex items-center">
              <img alt="workingtime" src="../assets/wokingtime_icon.svg" class="w-8 h-8 mr-2">
              Working Time
            </router-link>
          </li>
          <li v-if="isManagerOrGeneralManager" class="mb-2">
            <router-link to="/my-team" class="text-customWhite flex items-center">
              <img alt="team" src="../assets/team_icon.svg" class="w-8 h-8 mr-2">
              My Team
            </router-link>
          </li>
          <li v-if="isManagerOrGeneralManager" class="mb-2">
            <router-link to="/create-team" class="text-customWhite flex items-center">
              <img alt="create" src="../assets/plus.svg" class="w-8 h-8 mr-2">
              Create My Team
            </router-link>
          </li>
          <li v-if="isManagerOrGeneralManager" class="mb-2">
            <router-link to="/view-users" class="text-customWhite flex items-center">
              <img alt="users" src="../assets/users_icon.svg" class="w-8 h-8 mr-2">
              View Users
            </router-link>
          </li>
        </ul>

        <button class="error text-white px-4 py-2 mt-4 self-end" @click="logout">
          Logout
        </button>
      </nav>

      <main class="flex-grow p-4 overflow-auto pb-20">
        <router-view />
      </main>
    </div>

    <div class="bg-customMain p-4 sm:hidden fixed inset-x-0 bottom-0 flex justify-between text-center">
      <router-link :to="`/dashboard/${storedUserID}`" class="flex flex-col items-center">
        <img alt="dashboard" src="../assets/chart_icon.svg" class="w-8 h-8">
        <span class="text-xs text-customWhite">Dashboard</span>
      </router-link>
      <router-link :to="`/dashboard/working-times/${storedUserID}`" class="flex flex-col items-center">
        <img alt="workingtime" src="../assets/wokingtime_icon.svg" class="w-8 h-8 mr-2">
        <span class="text-xs text-customWhite">Working Time</span>
      </router-link>
      <router-link v-if="isManagerOrGeneralManager" to="/my-team" class="flex flex-col items-center">
        <img alt="team" src="../assets/team_icon.svg" class="w-8 h-8 mr-2">
        <span class="text-xs text-customWhite">My Team</span>
      </router-link>
      <router-link v-if="isManagerOrGeneralManager" to="/create-team" class="flex flex-col items-center">
        <img alt="create" src="../assets/plus.svg" class="w-8 h-8 mr-2">
        <span class="text-xs text-customWhite">Create My Team</span>
      </router-link>
      <router-link v-if="isManagerOrGeneralManager" to="/view-users" class="flex flex-col items-center">
        <img alt="users" src="../assets/users_icon.svg" class="w-8 h-8 mr-2">
        <span class="text-xs text-customWhite">View Users</span>
      </router-link>
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
