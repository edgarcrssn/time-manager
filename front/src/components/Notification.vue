<template>
  <div class="relative">
    <img v-if="!isOpen" alt="clockIn" src="../assets/clock-in.svg" class="w-8 h-8" @click="toggleDropdown">
    <img v-else alt="clockOut" src="../assets/clock-out.svg" class="w-8 h-8" @click="toggleDropdown">
    <div
      v-if="isOpen"
      ref="refDropdown"
      class="origin-top-right absolute right-0 mt-2 w-96 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 focus:outline-none"
      role="menu"
      aria-orientation="vertical"
      aria-labelledby="options-menu"
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
              class="w-4 h-4 ml-2 items-center"
              src="../assets/cross-small-svgrepo-com.svg"
              @click.stop="deleteNotificationInList(notification)"
            ></a>
          <a
            v-if="notification.type == 'warning'"
            href="#"
            class="rounded-xl px-4 py-2 text-sm text-gray-700 bg-yellow-500 flex"
            role="menuitem"
          >
            {{ notification.message }} : {{ notification.date.day }}/{{ notification.date.month }}/{{
              notification.date.year
            }}
            <img
              alt="deleteCross"
              class="w-4 h-4 ml-2 items-center"
              src="../assets/cross-small-svgrepo-com.svg"
              @click.stop="deleteNotificationInList(notification)"
            ></a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onUnmounted, onMounted, ref, Ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'
import { Notification } from '../models/Notification'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'
import { formatStringToCreateDate } from '../helpers/dateUtils'

const isOpen = ref<boolean>(false)
const refDropdown: Ref<HTMLElement | null> = ref(null)
const notificationList = ref<Notification[]>([])
const userId = sessionStorage.getItem('userID')

const handleOutsideClick = (event: MouseEvent) => {
  if (refDropdown.value && refDropdown.value.contains(event.target as Node)) {
    isOpen.value = false
  }
}
const toggleDropdown = (event: MouseEvent) => {
  event.stopPropagation()
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

onMounted(async () => {
  document.addEventListener('click', handleOutsideClick)
  await createNotificationInList()
})

onUnmounted(() => {
  document.removeEventListener('click', handleOutsideClick)
})
</script>
