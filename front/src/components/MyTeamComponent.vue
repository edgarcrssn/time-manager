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
    <div class="flex justify-between items-center">
      <button
        v-if="isManager"
        type="button"
        class="bg-main text-white px-4 py-2 mt-4 self-end"
        @click="openAddUserTeamModal"
      >
        Add a user in a team
      </button>
      <button
        v-if="isManager"
        type="button"
        class="bg-error text-white px-4 py-2 mt-4 self-end"
        @click="openDeleteUserTeamModal"
      >
        Delete a user of a team
      </button>
    </div>
    <section v-for="teamUserData in teamsUsersData" :key="teamUserData.team.id">
      <h3 class="text-center">
        {{ teamUserData.team.name }}
      </h3>
      <table class="w-full text-center">
        <thead>
          <tr>
            <th>Username</th>
            <th>Email</th>
            <th>Role</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="teamUserDataInUser in teamUserData.users" :key="teamUserDataInUser.id">
            <td>{{ teamUserDataInUser.username }}</td>
            <td>{{ teamUserDataInUser.email }}</td>
            <td>{{ teamUserDataInUser.role }}</td>
          </tr>
        </tbody>
      </table>
    </section>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import { apiUrl } from '../constants/urls'
import { User } from '../models/Users'
import Modal from './AddUserTeamPopUp.vue'

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
const userId = localStorage.getItem('userID')
const userList = ref<User[]>([])
const teamList = ref<TeamInterface[]>([])
const selectedTeam = ref<number>(0)
const selectedUser = ref<number>(0)
const getTeamsofUser = async () => {
  try {
    const response = await fetch(`${apiUrl}/api/teams/${userId}/team`)
    const data = await response.json()
    if (data) {
      teamsUsersData.value = data
    }
  } catch (error) {
    console.error('An error occured while the fetching of the data')
  }
}
onMounted(async () => {
  getTeamsofUser()
  populateTeamList()
  populateUserList()
  checkIsManager()
})

const checkIsManager = () => {
  const userRole = localStorage.getItem('userRole')
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
}

const openDeleteUserTeamModal = () => {
  isDeleteUserModalOpen.value = true
}

const closeDeleteUserTeamModal = () => {
  isDeleteUserModalOpen.value = false
  selectedTeam.value = 0
  selectedUser.value = 0
}

const addUserTeam = async (userId: number, teamId: number) => {
  try {
    const requestOptions = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    }
    fetch(`${apiUrl}/api/teams/${userId}/${teamId}`, requestOptions).then((response) => {
      if (!response.ok) {
        throw new Error('An error occured while the adding of the user in the team')
      } else {
        closeAddUserTeamModal()
      }
    })
  } catch (error) {
    console.error('An error occured while the adding of the user in the team')
  }
}

const deleteUserTeam = async (userId: number, teamId: number) => {
  try {
    const requestOptions = {
      method: 'DELETE',
      header: {
        'Content-Type': 'application/json'
      }
    }
    fetch(`${apiUrl}/api/teams/${userId}/${teamId}`, requestOptions).then((response) => {
      if (!response.ok) {
        throw new Error('An error occured while the deleting of the user in the team')
      } else {
        closeDeleteUserTeamModal()
      }
    })
  } catch (error) {
    console.error('An error occured while the deleting of the user in the team')
  }
}

const populateUserList = async () => {
  try {
    const response = await fetch(`${apiUrl}/api/users/`)
    const data = await response.json()
    if (data) {
      userList.value = data
    }
  } catch (error) {
    console.error('An error occured while the fetching of the users')
  }
}

const populateTeamList = async () => {
  try {
    const response = await fetch(`${apiUrl}/api/teams/`)
    const data = await response.json()
    if (data) {
      teamList.value = data
    }
  } catch (error) {
    console.error('An error occured while the fetching of the teams')
  }
}
</script>

<style scoped></style>
