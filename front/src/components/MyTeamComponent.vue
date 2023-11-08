<template>
  <div>
    <section>
      <Modal
        :is-open="isAddUserModalOpen"
        title="Add a user in a team"
        :is-delete="false"
        @close="closeAddUserTeamModal"
      >
        <form ref="userForm" @submit.prevent="addUserTeam(selectedUser, selectedTeam)">
          <div class="mb-4">
            <select
              v-model="selectedUser"
              class="block w-full mt-2 py-2 px-4 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-indigo-200 focus:border-indigo-500 overflow-y-auto"
            >
              <option :value="0" disabled selected>
                Select a user
              </option>
              <option v-for="userElt in userList" :key="userElt.id" :value="userElt.id">
                {{ userElt.email }}
              </option>
            </select>
          </div>
          <div class="mb-4">
            <select
              v-model="selectedTeam"
              class="block w-full mt-2 py-2 px-4 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-indigo-200 focus:border-indigo-500 overflow-y-auto"
            >
              <option :value="0" disabled selected>
                Select a team
              </option>
              <option v-for="teamElt in teamList" :key="teamElt.id" :value="teamElt.id">
                {{ teamElt.name }}
              </option>
            </select>
          </div>
          <div class="flex justify-between">
            <button type="submit" class="main">
              Confirm
            </button>
            <button type="button" class="error" @click="closeAddUserTeamModal">
              Close
            </button>
          </div>
        </form>
      </Modal>

      <Modal
        :is-open="isDeleteUserModalOpen"
        title="Delete a user of a team"
        :is-delete="true"
        @close="closeDeleteUserTeamModal"
      >
        <form ref="userForm" @submit.prevent="deleteUserTeam(selectedUser, selectedTeam)">
          <div class="mb-4">
            <select
              v-model="selectedUser"
              class="block w-full mt-2 py-2 px-4 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-indigo-200 focus:border-indigo-500 overflow-y-auto"
            >
              <option :value="0" disabled selected>
                Select a user
              </option>
              <option v-for="userElt in userList" :key="userElt.id" :value="userElt.id">
                {{ userElt.email }}
              </option>
            </select>
          </div>
          <div class="mb-4">
            <select
              v-model="selectedTeam"
              class="block w-full mt-2 py-2 px-4 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-indigo-200 focus:border-indigo-500 overflow-y-auto"
            >
              <option :value="0" disabled selected>
                Select a team
              </option>
              <option v-for="teamElt in teamList" :key="teamElt.id" :value="teamElt.id">
                {{ teamElt.name }}
              </option>
            </select>
          </div>
          <div class="flex justify-between">
            <button type="submit" class="main">
              Confirm
            </button>
            <button type="button" class="error" @click="closeDeleteUserTeamModal">
              Close
            </button>
          </div>
        </form>
      </Modal>
    </section>
    <h2 class="text-center">
      My Team(s)
    </h2>
    <div :key="refreshKey" class="flex justify-between items-center">
      <button v-if="isManager" type="button" class="main" @click="openAddUserTeamModal">
        Add a user in a team
      </button>
      <button v-if="isManager" type="button" class="error" @click="openDeleteUserTeamModal">
        Delete a user of a team
      </button>
    </div>
    <section v-for="teamUserData in teamsUsersData" :key="teamUserData.team.id">
      <h3 class="text-center">
        {{ teamUserData.team.name }}
      </h3>
      <div class="overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left text-white overflow-x-auto shadow-md sm:rounded-lg">
          <thead class="text-xs uppercase bg-customGrey">
            <tr>
              <th scope="col" class="px-6 py-3">
                Username
              </th>
              <th scope="col" class="px-6 py-3">
                Email
              </th>
              <th scope="col" class="px-6 py-3">
                Role
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(teamUserDataInUser, index) in teamUserData.users"
              :key="teamUserDataInUser.id"
              :class="
                index % 2 === 0 ? 'bg-customLightGrey border-b border-white' : 'bg-customGrey border-b border-white'
              "
            >
              <td class="px-6 py-4 font-medium whitespace-nowrap">
                {{ teamUserDataInUser.username }}
              </td>
              <td class="px-6 py-4">
                {{ teamUserDataInUser.email }}
              </td>
              <td class="px-6 py-4">
                {{ teamUserDataInUser.role }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { User } from '../models/Users'
import Modal from './AddUserTeamPopUp.vue'
import { fetchData } from '../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'

interface TeamInterface {
  id: number
  name: string
}

interface TeamsUsersInterface {
  // eslint-disable-next-line camelcase
  is_owner: boolean
  team: TeamInterface
  users: User[]
}

const isDeleteUserModalOpen = ref(false)
const isAddUserModalOpen = ref(false)
const teamsUsersData = ref<TeamsUsersInterface[]>([])
const isManager = ref(false)
const userId = sessionStorage.getItem('userID')
const userList = ref<User[]>([])
const teamList = ref<TeamInterface[]>([])
const selectedTeam = ref<number>(0)
const selectedUser = ref<number>(0)
const refreshKey = ref<number>(0)
const getTeamsofUser = async () => {
  try {
    const response = await fetchData(`${apiUrl}/api/teams/${userId}/team`, 'GET')
    if (response) {
      teamsUsersData.value = response
    }
  } catch (error) {
    createToast(
      { title: 'An error occurred while the fetching of the users' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('An error occurred while the fetching of the data')
  }
}
onMounted(async () => {
  getTeamsofUser()
  populateTeamList()
  populateUserList()
  checkIsManager()
})

const checkIsManager = () => {
  const userRole = sessionStorage.getItem('userRole')
  if (userRole === 'manager' || userRole === 'general_manager') {
    isManager.value = true
  } else {
    isManager.value = false
  }
}

const openAddUserTeamModal = () => {
  isAddUserModalOpen.value = true
}

const closeAddUserTeamModal = () => {
  isAddUserModalOpen.value = false
  selectedTeam.value = 0
  selectedUser.value = 0
  getTeamsofUser()
}

const openDeleteUserTeamModal = () => {
  isDeleteUserModalOpen.value = true
}

const closeDeleteUserTeamModal = () => {
  isDeleteUserModalOpen.value = false
  selectedTeam.value = 0
  selectedUser.value = 0
  getTeamsofUser()
}

const addUserTeam = async (userId: number, teamId: number) => {
  try {
    await fetchData(`${apiUrl}/api/teams/${userId}/${teamId}`, 'POST')
    createToast(
      { title: 'The user has been add in the team with success' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    closeAddUserTeamModal()
  } catch (error) {
    createToast(
      { title: 'An error occurred while the adding of the user in the team' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('An error occurred while the adding of the user in the team')
  }
}

const deleteUserTeam = async (userId: number, teamId: number) => {
  try {
    await fetchData(`${apiUrl}/api/teams/${userId}/${teamId}`, 'DELETE')
    createToast(
      { title: 'The user has been delete of the team with success' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    closeDeleteUserTeamModal()
  } catch (error) {
    createToast(
      { title: 'An error occurred while the deleting of the user in the team' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('An error occurred while the deleting of the user in the team')
  }
}

const populateUserList = async () => {
  try {
    const response = await fetchData(`${apiUrl}/api/users/`)
    if (response) {
      userList.value = response
    }
  } catch (error) {
    createToast(
      { title: 'An error occurred while the fetching of the users' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    console.error('An error occurred while the fetching of the users')
  }
}

const populateTeamList = async () => {
  try {
    const response = await fetchData(`${apiUrl}/api/teams/`)
    if (response) {
      teamList.value = response
    }
  } catch (error) {
    createToast(
      { title: 'An error occurred while the fetching of the team' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    console.error('An error occurred while the fetching of the teams')
  }
}
</script>

<style scoped></style>
