<template>
  <form @submit.prevent="addUser(selectedUserId)">
    <div class="mb-4">
      <select
        v-model="selectedUserId"
        :disabled="availableUsersAreLoading"
        class="block w-full mt-2 py-2 px-4 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-indigo-200 focus:border-indigo-500 overflow-y-auto"
      >
        <option :value="0" disabled selected>
          Select a user
        </option>
        <option v-for="user in availableUsers" :key="user.id" :value="user.id">
          {{ user.username }}
        </option>
      </select>
    </div>
    <div class="flex justify-between">
      <button :disabled="!selectedUserId || availableUsersAreLoading" type="submit" class="main">
        Confirm
      </button>
      <button
        type="button"
        class="error"
        @click="
          () => {
            onClose()
          }
        "
      >
        Close
      </button>
    </div>
  </form>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import { User } from '../../models/Users'
import { fetchData } from '../../services/httpService'
import { apiUrl } from '../../constants/urls'
import { createToast } from 'mosha-vue-toastify'

const { teamId, alreadyAddedUsersIds, onClose, onSuccess } = defineProps({
  teamId: {
    required: true,
    type: Number
  },
  alreadyAddedUsersIds: {
    required: false,
    type: Array as () => number[],
    default: () => []
  },
  onClose: {
    require: false,
    type: Function,
    default: () => {}
  },
  onSuccess: {
    require: false,
    type: Function,
    default: () => {}
  }
})

const selectedUserId = ref<number | null>(null)
const availableUsers = ref<User[]>([])
const availableUsersAreLoading = ref<boolean>(true)

onMounted(() => {
  fetchAvailableUsers()
})

const fetchAvailableUsers = async () => {
  availableUsersAreLoading.value = true
  try {
    const users: User[] = await fetchData(`${apiUrl}/api/users`)
    const usersWithoutAlreadyAddedUsers = users.filter((user) => !alreadyAddedUsersIds.includes(user.id))
    availableUsers.value = usersWithoutAlreadyAddedUsers
  } catch (error) {
    console.error(error)
  } finally {
    availableUsersAreLoading.value = false
  }
}

const addUser = async (userId: number | null) => {
  if (!userId) return

  try {
    await fetchData(`${apiUrl}/api/teams/${userId}/${teamId}`, 'POST')
    createToast(
      { title: 'The user has successfully been added' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
    onSuccess()
  } catch (error) {
    createToast(
      { title: 'An error occurred while adding the user' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('An error occurred while adding the user')
  }
}
</script>

<style scoped></style>
