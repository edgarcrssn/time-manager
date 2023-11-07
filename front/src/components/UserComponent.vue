<template>
  <section>
    <h2>Manage user</h2>
    <button class="main" @click="openUserModal">
      Add User
    </button>

    <Modal :is-open="isUserModalOpen" title="Créer un utilisateur" @close="closeUserModal">
      <form ref="userForm" @submit.prevent="createUser">
        <div class="mb-4">
          <label for="username" class="block text-sm font-medium text-gray-600">Username</label>
          <input id="username" v-model="userInput.username" type="text" class="mt-1 p-2 w-full border rounded">
        </div>
        <div class="mb-4">
          <label for="email" class="block text-sm font-medium text-gray-600">Mail</label>
          <input id="email" v-model="userInput.email" type="email" class="mt-1 p-2 w-full border rounded">
        </div>
        <select id="role" v-model="userInput.role" class="mt-1 p-2 w-full border rounded">
          <option value="employee">
            Employee
          </option>
          <option value="manager">
            Manager
          </option>
          <option v-if="isGeneralManager" value="general manager">
            General Manager
          </option>
        </select>
        <div class="flex justify-between">
          <button type="submit" class="main">
            Confirm
          </button>
          <button type="button" class="error" @click="closeUserModal">
            Close
          </button>
        </div>
      </form>
    </Modal>

    <Modal :is-open="isScheduleModalOpen" title="Horaires de l'utilisateur" @close="closeScheduleModal">
      <form ref="scheduleForm" @submit.prevent="updateOrCreateSchedule">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-600">Working days</label>
          <div class="mt-2">
            <label for="monday" class="mr-2">
              <input id="monday" v-model="schedule.monday" type="checkbox"> Monday
            </label>
            <label for="tuesday" class="mr-2">
              <input id="tuesday" v-model="schedule.tuesday" type="checkbox"> Tuesday
            </label>
            <label for="wednesday" class="mr-2">
              <input id="wednesday" v-model="schedule.wednesday" type="checkbox"> Wednesday
            </label>
            <label for="thursday" class="mr-2">
              <input id="thursday" v-model="schedule.thursday" type="checkbox"> Thursday
            </label>
            <label for="saturday" class="mr-2">
              <input id="saturday" v-model="schedule.saturday" type="checkbox"> Saturday
            </label>
            <label for="sunday"> <input id="sunday" v-model="schedule.sunday" type="checkbox"> Sunday </label>
          </div>
        </div>
        <div class="mb-4">
          <label for="start_time" class="block text-sm font-medium text-gray-600">Start time</label>
          <input id="start_time" v-model="schedule.start_time" type="time" class="mt-1 p-2 w-full border rounded">
        </div>
        <div class="mb-4">
          <label for="end_time" class="block text-sm font-medium text-gray-600">End time</label>
          <input id="end_time" v-model="schedule.end_time" type="time" class="mt-1 p-2 w-full border rounded">
        </div>
        <div class="flex justify-between">
          <button type="submit" class="main">
            Update
          </button>
          <button type="button" class="error" @click="closeScheduleModal">
            Close
          </button>
        </div>
      </form>
    </Modal>

    <h2 v-if="isManager && usersData.length > 0" class="text-center">
      Table of the users
    </h2>
    <TableComponent
      v-if="isManager"
      :key="refreshKey"
      :title-property="['Username', 'Email', 'Actions']"
      :data="usersData"
      :table-name="'Table of Users'"
      :type-table="'user'"
      @itemDeleted="handleItemDeleted"
      @addItem="handleItemAdded"
      @showSchedule="openScheduleModal"
    />
  </section>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import TableComponent from './table/TableComponent.vue'
import Modal from './PopUp.vue'
import { User } from '../models/Users'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

const refreshKey = ref(0)
const userId = sessionStorage.getItem('userID')
const getUserUrl = `${apiUrl}/api/users/${userId}`
const usersData = ref<User[]>([])
const isManager = ref(false)
const userForm = ref(null)
const isUserModalOpen = ref(false)
const isScheduleModalOpen = ref(false)
const isGeneralManager = ref(false)

const openUserModal = () => {
  isUserModalOpen.value = true
}

const closeUserModal = () => {
  isUserModalOpen.value = false
}

const openScheduleModal = (clickedUserId: number) => {
  isScheduleModalOpen.value = true
  getScheduleData(clickedUserId)
}

const closeScheduleModal = () => {
  isScheduleModalOpen.value = false
}

const emit = defineEmits(['close', 'addItem'])
const userInput = ref({
  username: '',
  email: '',
  role: 'employee'
})

const schedule = ref<{
  id: number | null
  monday: boolean
  tuesday: boolean
  wednesday: boolean
  friday?: boolean
  thursday: boolean
  saturday: boolean
  sunday: boolean
  start_time: string
  end_time: string
}>({
  id: null,
  monday: false,
  tuesday: false,
  wednesday: false,
  thursday: false,
  saturday: false,
  sunday: false,
  start_time: '',
  end_time: ''
})

const updateOrCreateSchedule = async () => {
  const dataToSend = {
    schedule: { ...schedule.value }
  }

  try {
    const data = await fetchData(`${apiUrl}/api/schedules/${schedule.value.id}`, 'PUT', dataToSend)

    if (data) {
      closeScheduleModal()
    } else {
      console.error('error')
    }
  } catch (error: unknown) {
    if (error instanceof Error && 'status' in error) {
      const errorWithStatus = error as Error & { status: number };
      if (errorWithStatus.status === 404) {
        await createSchedule(dataToSend);
      } else {
        console.error(`Failed to update schedule for user ${schedule.value.id}`, error);
      }
    } else {
      console.error('Error with the schedule operation:', error);
    }
  }
}

const createSchedule = async (dataToSend: any) => {
  try {
    const data = await fetchData(`${apiUrl}/api/schedules/${schedule.value.id}`, 'POST', dataToSend)

    if (data) {
      closeScheduleModal()
    } else {
      console.error('error')
    }
  } catch (error) {
    console.error('Error creating schedule:', error)
  }
}

const getScheduleData = async (userId: number) => {
  schedule.value = {
    id: userId,
    monday: false,
    tuesday: false,
    wednesday: false,
    thursday: false,
    friday: false,
    saturday: false,
    sunday: false,
    start_time: '',
    end_time: ''
  }

  try {
    const scheduleData = await fetchData(`${apiUrl}/api/schedules/${userId}`)
    if (scheduleData) {
      schedule.value = { ...scheduleData, id: userId }
    }
  } catch (error) {
    console.error(`Error fetching schedule for user ${userId}:`, error)
  }
}

const createUser = async () => {
  if (isUserModalOpen.value) {
    try {
      const userData = {
        user: {
          username: userInput.value.username,
          email: userInput.value.email,
          role: userInput.value.role
        }
      }
      await fetchData(`${apiUrl}/api/users`, 'POST', userData)
      emit('addItem')
      closeUserModal()
    } catch (error) {
      console.error(error)
    }
  }
}

const getUser = async () => {
  try {
    const data = await fetchData(getUserUrl, 'GET')
    if (data.role === 'general_manager') {
      isGeneralManager.value = true
    }

    if (data && (data.role === 'manager' || data.role === 'general_manager')) {
      isManager.value = true
      try {
        const dataUsers = await fetchData(`${apiUrl}/api/users`, 'GET')
        if (dataUsers) {
          usersData.value = dataUsers
        }
      } catch (error) {
        console.error('Error while fetching all the users data')
      }
    }
  } catch (error) {
    console.error(error)
  }
}

onMounted(async () => {
  getUser()
})

const handleItemDeleted = (itemId: number) => {
  usersData.value = usersData.value.filter((user) => user.id !== itemId)
}

const handleItemAdded = async () => {
  try {
    const getAllUsersUrl = `${apiUrl}/api/users`
    const responseAllUsers = await fetch(getAllUsersUrl)
    const dataUsers = await responseAllUsers.json()
    if (dataUsers) {
      usersData.value = dataUsers
    }
  } catch (error) {
    console.error('Error while fetching all the users data')
  }
}
</script>

<style scoped></style>
