<template>
  <div class="h-screen flex flex-col">
    <header class="bg-gray-800 text-white p-4 flex items-center justify-between">
      <h1 class="text-center flex-grow">
        Dashboard
      </h1>
      <router-link
        :to="`/dashboard/profile/${storedUserID}`"
        class="ml-4"
      >
        <img
          alt="profile"
          src="../assets/user_icon.svg"
          class="w-5 h-5"
        >
      </router-link>
    </header>

    <div class="flex flex-row h-full">
      <nav class="bg-gray-200 p-4 w-[300px] flex-shrink-0 flex flex-col">
        <ul>
          <li class="mb-2">
            <router-link
              :to="`/dashboard/${storedUserID}`"
              class="text-gray-700"
            >
              My Dashboard
            </router-link>
          </li>
          <li class="mb-2">
            <router-link
              :to="`/dashboard/working-times/${storedUserID}`"
              class="text-gray-700"
            >
              Working Time
            </router-link>
          </li>
          <li
            v-if="isManagerOrGeneralManager"
            class="mb-2"
          >
            <router-link
              to="/my-team"
              class="text-gray-700"
            >
              My Team
            </router-link>
          </li>
          <li
            v-if="isManagerOrGeneralManager"
            class="mb-2"
          >
            <router-link
              to="/create-team"
              class="text-gray-700"
            >
              Create My Team
            </router-link>
          </li>
          <li
            v-if="isManagerOrGeneralManager"
            class="mb-2"
          >
            <router-link
              to="/view-users"
              class="text-gray-700"
            >
              View Users
            </router-link>
          </li>
        </ul>

        <button
          class="bg-red-500 text-white px-4 py-2 mt-4 self-end"
          @click="logout"
        >
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

const router = useRouter()
const storedUserID = ref('')

const logout = () => {
  localStorage.removeItem('userID')
  localStorage.removeItem('userRole')
  router.push('/')
}

const isManagerOrGeneralManager = computed(() => {
  const storedUserRole = localStorage.getItem('userRole')
  return storedUserRole === 'manager' || storedUserRole === 'general_manager'
})

const getUserInfo = () => {
  const userID = localStorage.getItem('userID')
  if (!userID) return
  storedUserID.value = userID
}

onMounted(() => {
  getUserInfo()
})
</script>
