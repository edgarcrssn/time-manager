<template>
  <div class="h-screen flex flex-col">
    <header class="bg-gray-800 text-white p-4 text-center">
      <h1>Dashboard</h1>
    </header>

    <div class="flex flex-row h-full">
      <nav class="bg-gray-200 p-4 w-[300px] flex-shrink-0 flex flex-col">
        <ul>
          <li class="mb-2">
            <router-link
              to="/dashboard"
              class="text-gray-700"
            >
              My Dashboard
            </router-link>
          </li>
          <li class="mb-2">
            <router-link
              to="/working-times"
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
          <li class="mb-2">
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
import { computed } from 'vue'

const router = useRouter()

const logout = () => {
  localStorage.removeItem('userID')
  localStorage.removeItem('userRole')
  router.push('/')
}

const isManagerOrGeneralManager = computed(() => {
  const storedUserRole = localStorage.getItem('userRole')
  return storedUserRole === 'manager' || storedUserRole === 'general_manager'
})
</script>
