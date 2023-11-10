<template>
  <div class="h-screen flex flex-col">
    <header class="bg-customMain text-white p-4 flex items-center justify-between">
      <div class="flex-1 sm:invisible" @click="logout">
        <img src="../assets/logout.svg" class="w-8 h-8">
      </div>
      <h1 class="flex-1 text-center">
        EpicHourly
      </h1>

      <div class="relative inline-block text-right w-80 py-1 px-1">
        <button
          type="button"
          class="inline-flex items-center text-center px-1 py-1 border rounded-md shadow-sm text-sm font-medium bg-black focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          @click="toggleDropdown"
        >
          <img alt="clockIn" src="../assets/clock-in.svg" class="w-8 h-8">
          <svg
            class="-mr-1 ml-2 h-5 w-5"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fill-rule="evenodd"
              d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
        <div
          v-if="isOpen"
          class="origin-top-center absolute right-0 mt-2 w-full rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 focus:outline-none"
          role="menu"
          aria-orientation="vertical"
          aria-labelledby="options-menu"
          @click="toggleDropdown"
        >
          <div class="py-1 text-center" role="none">
            <p v-if="notificationList.length == 0" class="text-black">
              You don't have notifications
            </p>
            <div v-for="notification in notificationList" :key="notification.message">
              <a
                v-if="notification.type == 'info'"
                href="#"
                class="rounded-xl px-4 py-2 text-sm text-gray-700 flex"
                role="menuitem"
              >
                {{ notification.message }} : {{ notification.date.day }}/{{ notification.date.month }}/
                {{ notification.date.year }}
                <img
                  alt="deleteCross"
                  class="w-4 h-4 items-center"
                  src="../assets/cross-small-svgrepo-com.svg"
                  @click="deleteNotificationInList(notification)"
                ></a>
              <a
                v-if="notification.type == 'warning'"
                href="#"
                class="rounded-xl px-4 py-2 text-sm text-gray-700 bg-yellow-500 flex"
                role="menuitem"
              >
                {{ notification.message }} : {{ notification.date.day }}/{{ notification.date.month }}/
                {{ notification.date.year }}
                <img
                  alt="deleteCross"
                  class="w-4 h-4 items-center"
                  src="../assets/cross-small-svgrepo-com.svg"
                  @click="deleteNotificationInList(notification)"
                ></a>
            </div>
          </div>
        </div>
      </div>
      <router-link :to="`/dashboard/profile/${storedUserID}`" class="flex justify-end">
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
          <li class="mb-2">
            <router-link to="/dashboard/teams" class="text-customWhite flex items-center">
              <img alt="team" src="../assets/team_icon.svg" class="w-8 h-8 mr-2">
              Teams
            </router-link>
          </li>
          <li v-if="isManagerOrGeneralManager" class="mb-2">
            <router-link to="/dashboard/view-users" class="text-customWhite flex items-center">
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
      <router-link to="/dashboard/teams" class="flex flex-col items-center">
        <img alt="team" src="../assets/team_icon.svg" class="w-8 h-8 mr-2">
        <span class="text-xs text-customWhite">Teams</span>
      </router-link>
      <router-link v-if="isManagerOrGeneralManager" to="/dashboard/view-users" class="flex flex-col items-center">
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
import { Notification } from '../models/Notification'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'
import { formatStringToCreateDate } from '../helpers/dateUtils'

const router = useRouter()
const storedUserID = ref('')
const isOpen = ref<boolean>(false)
const notificationList = ref<Notification[]>([])
const userId = sessionStorage.getItem('userID')

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

const toggleDropdown = () => {
  isOpen.value = !isOpen.value
}

const createNotificationInList = async () => {
  const today = new Date()
  var isLate = false
  var isWorkLate = false
  const dataUserSchedule = await fetchData(`${apiUrl}/api/schedules/${userId}`)
  if (!dataUserSchedule) {
    createToast(
      { title: 'Please enter your working schedule' },
      { transition: 'zoom', timeout: 8000, type: 'warning', position: 'bottom-right' }
    )
  }
  const clockStatus = await fetchData(`${apiUrl}/api/clocks/${userId}/last`)
  const clockDateStart = new Date(formatStringToCreateDate(today, dataUserSchedule.start_time))
  if (clockDateStart < today && !clockStatus.clock.status) {
    isLate = true
  }
  const clockDateEnd = new Date(formatStringToCreateDate(today, dataUserSchedule.end_time))
  if (clockDateEnd > today && clockStatus.clock.status) {
    isWorkLate = true
  }
  if (isLate) {
    const newNotification = {
      message: "You are late at your work, please clock'in",
      type: 'warning',
      date: { day: today.getDate(), month: today.getMonth(), year: today.getFullYear() }
    }
    notificationList.value.push(newNotification)
  }

  // vérifier si l'utilisateur fait des heures supplémentaires
  if (isWorkLate) {
    const newNotification = {
      message: "You work hard today, don't forget to clock'out",
      type: 'warning',
      date: { day: today.getDate(), month: today.getMonth(), year: today.getFullYear() }
    }
    notificationList.value.push(newNotification)
  }
}

const deleteNotificationInList = (notification: Notification) => {
  const tempNotificationList = notificationList.value.filter((item) => item !== notification)
  notificationList.value = tempNotificationList
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

onMounted(async () => {
  getUserInfo()
  await createNotificationInList()
})
</script>
