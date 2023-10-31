<template>
  <section>
    <h2>
      Manage user
    </h2>
    <button class="main" @click="openUserModal">
      Add User
    </button>

    <Modal :is-open="isUserModalOpen" @close="closeUserModal" title="Créer un utilisateur">
      <form ref="userForm" @submit.prevent="createUser">
        <div class="mb-4">
          <label for="username" class="block text-sm font-medium text-gray-600">Nom d'utilisateur</label>
          <input type="text" id="username" v-model="userInput.username" class="mt-1 p-2 w-full border rounded">
        </div>
        <div class="mb-4">
          <label for="email" class="block text-sm font-medium text-gray-600">Adresse email</label>
          <input type="email" id="email" v-model="userInput.email" class="mt-1 p-2 w-full border rounded">
        </div>
        <div class="flex justify-between">
          <button type="submit" class="main">Confirmer</button>
          <button type="button" @click="closeUserModal" class="error">Fermer</button>
        </div>
      </form>
    </Modal>

    <Modal :is-open="isScheduleModalOpen" @close="closeScheduleModal" title="Horaires de l'utilisateur">
      <form ref="scheduleForm" @submit.prevent="updateOrCreateSchedule">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-600">Jours de travail</label>
          <div class="mt-2">
            <label for="monday" class="mr-2">
              <input type="checkbox" id="monday" v-model="schedule.monday"> Lundi
            </label>
            <label for="tuesday" class="mr-2">
              <input type="checkbox" id="tuesday" v-model="schedule.tuesday"> Mardi
            </label>
            <label for="wednesday" class="mr-2">
              <input type="checkbox" id="wednesday" v-model="schedule.wednesday"> Mercredi
            </label>
            <label for="thursday" class="mr-2">
              <input type="checkbox" id="thursday" v-model="schedule.thursday"> Jeudi
            </label>
            <label for="saturday" class="mr-2">
              <input type="checkbox" id="saturday" v-model="schedule.saturday"> Samedi
            </label>
            <label for="sunday">
              <input type="checkbox" id="sunday" v-model="schedule.sunday"> Dimanche
            </label>
          </div>
        </div>
        <div class="mb-4">
          <label for="start_time" class="block text-sm font-medium text-gray-600">Heure de début</label>
          <input type="time" id="start_time" v-model="schedule.start_time" class="mt-1 p-2 w-full border rounded">
        </div>
        <div class="mb-4">
          <label for="end_time" class="block text-sm font-medium text-gray-600">Heure de fin</label>
          <input type="time" id="end_time" v-model="schedule.end_time" class="mt-1 p-2 w-full border rounded">
        </div>
        <div class="flex justify-between">
          <button type="submit" class="main">Mettre à jour</button>
          <button type="button" @click="closeScheduleModal" class="error">Fermer</button>
        </div>
      </form>
    </Modal>

    <h2 v-if="isManager && usersData.length > 0" class="text-center">
      Table of the users
    </h2>
    <TableComponent v-if="isManager" :key="refreshKey" :title-property="['Username', 'Email', 'Actions']"
      :data="usersData" :table-name="'Table of Users'" :type-table="'user'" @itemDeleted="handleItemDeleted"
      @addItem="handleItemAdded" @showSchedule="openScheduleModal" />
  </section>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import TableComponent from './table/TableComponent.vue'
import Modal from './PopUp.vue'
import { User } from '../models/Users'

const refreshKey = ref(0)
const userId = localStorage.getItem('userID')
const getUserUrl = `${import.meta.env.VITE_API_URL}/api/users/${userId}`
const usersData = ref<User[]>([])
const isManager = ref(false)
const userForm = ref(null)
const isUserModalOpen = ref(false)
const isScheduleModalOpen = ref(false)

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
  email: ''
})

const schedule = ref({
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

const updateOrCreateSchedule = () => {
  const myHeaders = new Headers();
  myHeaders.append("Content-Type", "application/json");

  const dataToSend = {
    schedule: { ...schedule.value }
  };
  const raw = JSON.stringify(dataToSend);

  const updateRequestOptions: RequestInit = {
    method: 'PUT',
    body: raw,
    headers: myHeaders,
    redirect: 'follow'
  }

  fetch(`${import.meta.env.VITE_API_URL}/api/schedules/${schedule.value.id}`, updateRequestOptions)
    .then((response: Response) => response.json().then(data => {
      if (response.ok) {
        closeScheduleModal();
      } else if (response.status === 404) {
        createSchedule(dataToSend);
      } else {
        console.error(`Failed to update schedule for user ${schedule.value.id}`, data);
      }
    }))
    .catch((error: Error) => console.error(error));
}

const createSchedule = (data: any) => {
  const myHeaders = new Headers();
  myHeaders.append("Content-Type", "application/json");

  const raw = JSON.stringify(data);

  const createRequestOptions: RequestInit = {
    method: 'POST',
    body: raw,
    headers: myHeaders,
    redirect: 'follow'
  }

  fetch(`${import.meta.env.VITE_API_URL}/api/schedules`, createRequestOptions)
    .then((response: Response) => response.json().then(data => {
      if (response.ok) {
        closeScheduleModal();
      } else {
        console.error(`Failed to create schedule`, data);
      }
    }))
    .catch((error: Error) => console.error(error));
}


const getScheduleData = (userId: number) => {
  fetch(`${import.meta.env.VITE_API_URL}/api/schedules/${userId}`)
    .then((response: Response) => response.json())
    .then((data) => {
      schedule.value = data
    })
    .catch((error: Error) => console.error(error))
}

const createUser = () => {
  if (isUserModalOpen.value = true) {
    var myHeaders = new Headers()
    myHeaders.append("Content-Type", "application/json")
    var raw = JSON.stringify({
      "user": {
        "username": `${userInput.value.username}`,
        "email": `${userInput.value.email}`
      }
    })
    const requestOptions: RequestInit = {
      method: 'POST',
      body: raw,
      headers: myHeaders,
      redirect: 'follow'
    }
    fetch(`${import.meta.env.VITE_API_URL}/api/users`, requestOptions)
      .then((response: Response) => {
        if (response.ok) {
          emit('addItem')
          closeUserModal()
        }
      })
      .catch((error: Error) => console.error(error))
  }
}

const getUser = async () => {
  try {
    const response = await fetch(getUserUrl)
    const data = await response.json()
    if (data) {
      if (data.role === 'manager' || data.role === 'general_manager') {
        isManager.value = true
        // get all the users of the database
        try {
          const getAllUsersUrl = `${import.meta.env.VITE_API_URL}/api/users`
          const responseAllUsers = await fetch(getAllUsersUrl)
          const dataUsers = await responseAllUsers.json()
          if (dataUsers) {
            usersData.value = dataUsers
          }
        } catch (error) {
          console.error('Error while fetching all the users data')
        }
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
    const getAllUsersUrl = `${import.meta.env.VITE_API_URL}/api/users`
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
