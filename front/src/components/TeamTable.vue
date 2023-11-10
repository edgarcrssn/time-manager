<template>
  <section class="[&:not(:last-of-type)]:mb-6">
    <div class="flex items-center justify-between mb-3 gap-2">
      <div class="flex items-center gap-2">
        <div v-if="iAmOwner" @click="toggleEditingTeamName">
          <img
            v-if="editingTeamName"
            alt="save team name"
            src="../assets/save_icon.svg"
            class="cursor-pointer w-4 h-4"
          >
          <img v-else alt="edit team name" src="../assets/edit_icon.svg" class="cursor-pointer w-4 h-4">
        </div>
        <h4 v-if="!editingTeamName" class="mb-0">
          {{ currentTeamName }}
        </h4>
        <input v-else v-model="newTeamName" type="text">
      </div>
      <button v-if="iAmOwner" type="button" class="error mt-0" @click="deleteTeam">
        <img alt="delete" src="../assets/delete_icon.svg" class="w-5 h-5">
      </button>
    </div>
    <div class="overflow-x-auto shadow-md sm:rounded-lg">
      <table class="w-full text-sm text-left text-white overflow-x-auto shadow-md sm:rounded-lg table-auto">
        <thead class="text-xs uppercase bg-customMain">
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
            <th v-if="iAmOwner" scope="col" class="px-6 py-3">
              Clock
            </th>
            <th scope="col" class="px-6 py-3">
              Action
            </th>
          </tr>
        </thead>
        <tbody>
          <p v-if="teamUsersAreLoading">
            Loading...
          </p>
          <tr
            v-for="(user, index) in teamUsers"
            v-else
            :key="user.id"
            :class="
              index % 2 === 0 ? 'bg-customSecondary border-b border-white' : 'bg-customMain border-b border-white'
            "
          >
            <td class="px-6 py-4 font-medium whitespace-nowrap">
              <img v-if="user.id === +(myId || 0)" alt="you" src="../assets/pin_icon.svg" class="inline w-5 h-5">
              <img v-if="user.is_owner" alt="owner" src="../assets/crown_icon.svg" class="inline w-5 h-5">
              {{ user.username }}
            </td>
            <td class="px-6 py-4">
              {{ user.email }}
            </td>
            <td class="px-6 py-4">
              {{ getRoleLabel(user.role) }}
            </td>
            <td v-if="iAmOwner" class="px-6 py-4">
              <UserClock :key="`userClock-${user.id}-${refresh}`" :user-id="user.id" :tiny="true" :on-clock="onClock" />
            </td>
            <td class="px-6 py-4">
              <div v-if="user.id === +(myId || 0) && !iAmOwner" class="flex items-center gap-1">
                <img
                  alt="leave team"
                  src="../assets/logout.svg"
                  class="cursor-pointer w-4 h-4"
                  @click="deleteUserFromTeam(user.id)"
                >
              </div>
              <div v-else-if="user.id !== +(myId || 0) && iAmOwner" class="flex items-center gap-1">
                <img
                  alt="delete user"
                  src="../assets/delete_icon.svg"
                  class="cursor-pointer w-4 h-4"
                  @click="deleteUserFromTeam(user.id)"
                >
                <img
                  alt="grant ownership"
                  src="../assets/crown_icon.svg"
                  class="cursor-pointer w-4 h-4"
                  @click="grantOwnershipToUser(user.id)"
                >
              </div>
            </td>
          </tr>
        </tbody>
      </table>
      <div
        v-if="iAmOwner"
        class="flex justify-center cursor-pointer transition duration-300 ease-in-out"
        :class="
          teamUsers.length % 2 === 0
            ? 'bg-customSecondary hover:bg-customMain border-b border-white'
            : 'bg-customMain hover:bg-customSecondary border-b border-white'
        "
        @click="openAddUserModal"
      >
        <img alt="add" src="../assets/plus.svg" class="my-2 w-5 h-5">
      </div>
      <Modal :is-open="addUserModalIsOpen" title="Add a user" :is-delete="false" :on-close="closeAddUserModal">
        <AddUserInTeamForm
          :team-id="team.id"
          :already-added-users-ids="teamUsers.map((user) => user.id)"
          :on-close="closeAddUserModal"
          :on-success="
            () => {
              closeAddUserModal()
              fetchTeamUsers()
            }
          "
        />
      </Modal>
    </div>
  </section>
</template>

<script lang="ts" setup>
import { onMounted, ref, watch } from 'vue'
import { Team } from '../models/Teams'
import { fetchData } from '../services/httpService'
import { apiUrl } from '../constants/urls'
import { Role } from '../models/Users'
import { getRoleLabel } from '../helpers/getRoleLabel'
import UserClock from './UserClock.vue'
import Modal from './Modal.vue'
import AddUserInTeamForm from './forms/AddUserInTeamForm.vue'
import { createToast } from 'mosha-vue-toastify'

const { team, onClock, refresh, fetchMyTeams } = defineProps({
  team: {
    required: true,
    type: Object as () => Team
  },
  onClock: {
    require: false,
    type: Function,
    default: () => {}
  },
  refresh: {
    require: false,
    type: Number,
    default: 0
  },
  fetchMyTeams: {
    require: false,
    type: Function,
    default: () => {}
  }
})

type TeamUser = {
  id: number
  username: string
  email: string
  role: Role
  is_owner: boolean
}

const myId = sessionStorage.getItem('userID')

const teamUsers = ref<TeamUser[]>([])
const teamUsersAreLoading = ref<boolean>(true)
const iAmOwner = ref<boolean>(false)

const editingTeamName = ref<boolean>(false)
const currentTeamName = ref<string>(team.name)
const newTeamName = ref<string>(team.name)

const addUserModalIsOpen = ref<boolean>(false)

onMounted(() => {
  fetchTeamUsers()
})

const fetchTeamUsers = async () => {
  teamUsersAreLoading.value = true
  try {
    const data: { users: TeamUser[] } | null = await fetchData(`${apiUrl}/api/teams/${team.id}/users`)
    teamUsers.value = data?.users ? data.users.sort((_, b) => (b.is_owner ? 1 : -1)) : []
  } catch (error) {
    console.error(error)
  } finally {
    teamUsersAreLoading.value = false
  }
}

watch(teamUsers, (newTeamUsers) => {
  if (newTeamUsers.length) {
    const teamOwnerId = newTeamUsers.find((user) => user.is_owner)?.id
    if (!teamOwnerId || !myId) {
      iAmOwner.value = false
    } else {
      iAmOwner.value = +myId === teamOwnerId
    }
  } else {
    iAmOwner.value = false
  }
})

const deleteTeam = async () => {
  try {
    await fetchData(`${apiUrl}/api/teams/${team.id}`, 'DELETE')
    fetchMyTeams()
    createToast(
      { title: 'The team has successfully been deleted' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
  } catch (error) {
    createToast(
      { title: 'An error occurred while deleting the team' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error(error)
  }
}

const toggleEditingTeamName = () => {
  if (editingTeamName.value) {
    updateTeamName()
  } else {
    editingTeamName.value = true
  }
}
const updateTeamName = async () => {
  if (!newTeamName.value.trim()) return
  if (newTeamName.value.trim() === currentTeamName.value.trim()) return

  try {
    const body = {
      team: {
        name: newTeamName.value.trim()
      }
    }
    await fetchData(`${apiUrl}/api/teams/${team.id}`, 'PATCH', body)
    currentTeamName.value = newTeamName.value.trim()
  } catch (error) {
    currentTeamName.value = team.name
    newTeamName.value = team.name
    console.error(error)
  } finally {
    editingTeamName.value = false
  }
}

const deleteUserFromTeam = async (userId: number) => {
  try {
    await fetchData(`${apiUrl}/api/teams/${userId}/${team.id}`, 'DELETE')
    createToast(
      { title: 'The user has successfully been deleted from the team' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    if (userId === +(myId || 0)) fetchMyTeams()
    else fetchTeamUsers()
  } catch (error) {
    createToast(
      { title: 'An error occurred while deleting the user from the team' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('An error occurred while deleting the user from the team')
  }
}
const grantOwnershipToUser = async (userId: number) => {
  try {
    await fetchData(`${apiUrl}/api/teams/${team.id}/grant-owner/${userId}`, 'PATCH')
    fetchTeamUsers()
    createToast(
      { title: 'The ownership has successfully been granted' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
  } catch (error) {
    createToast(
      { title: 'An error occurred while granting the ownership' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error(error)
  }
}

const openAddUserModal = () => {
  addUserModalIsOpen.value = true
}
const closeAddUserModal = () => {
  addUserModalIsOpen.value = false
}
</script>

<style scoped></style>
