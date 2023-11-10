<template>
  <div class="overflow-hidden">
    <div class="overflow-x-auto shadow-md sm:rounded-lg">
      <table class="w-full text-sm text-left text-white">
        <thead class="text-xs uppercase bg-customMain">
          <tr>
            <th v-for="thName in titleProperty" :key="thName" scope="col" class="px-6 py-3">
              {{ thName }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(donnee, index) in data"
            v-if="typeTable == 'user'"
            :key="donnee"
            :class="
              index % 2 === 0 ? 'bg-customSecondary border-b border-white' : 'bg-customMain border-b border-white'
            "
          >
            <th scope="row" class="px-6 py-4 font-medium whitespace-nowrap">
              {{ donnee.username }}
            </th>
            <td class="px-6 py-4">
              {{ donnee.email }}
            </td>
            <td class="px-6 py-4">
              <button class="mt-0" type="button" @click="$emit('showSchedule', donnee.id)">
                <img alt="calendar" src="../../assets/calendar_icon.svg" class="w-5 h-5">
              </button>
              <button class="mt-0" type="button" @click="openUpdateModal(donnee)">
                <img alt="update" src="../../assets/update_icon.svg" class="w-5 h-5">
              </button>
              <button class="mt-0" type="button" @click="deleteUser(donnee.id)">
                <img alt="delete" src="../../assets/delete_icon.svg" class="w-5 h-5">
              </button>
            </td>
          </tr>

          <tr
            v-for="(time, index) in data"
            v-if="typeTable == 'workingTimes'"
            :key="time.id"
            :class="
              index % 2 === 0 ? 'bg-customSecondary border-b border-white' : 'bg-customMain border-b border-white'
            "
          >
            <th scope="row" class="px-6 py-4 font-medium whitespace-nowrap">
              {{ time.id }}
            </th>
            <td class="px-6 py-4">
              {{ formatDate(time.start) }}
            </td>
            <td class="px-6 py-4">
              {{ formatDate(time.end) }}
            </td>
            <td class="px-6 py-4">
              {{ time.user_id }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <Modal :is-open="isModalOpen" title="Update User">
      <form v-if="userToUpdate" @submit.prevent="updateUser(userToUpdate.id)">
        <input v-model="userToUpdate.username" placeholder="Username">
        <input v-model="userToUpdate.email" placeholder="Email">
        <select v-model="userToUpdate.role">
          <option value="employee">
            Employee
          </option>
          <option value="manager">
            Manager
          </option>
          <option value="general_manager">
            General Manager
          </option>
        </select>
        <input v-model="userToUpdate.hourly_rate" type="integer" placeholder="Hourly Rate">
        <button type="submit">
          Update
        </button>
        <button @click="isModalOpen = false">
          Cancel
        </button>
      </form>
    </Modal>
  </div>
</template>

<script lang="ts" setup>
import { formatDate } from '../../helpers/dateUtils'
import { apiUrl } from '../../constants/urls'
import { fetchData } from '../../services/httpService'
import Modal from '../Modal.vue'
import { ref } from 'vue'
import type { User } from '../../models/Users'

const isModalOpen = ref(false)
const userToUpdate = ref<User | null>(null)

const emit = defineEmits(['itemDeleted', 'showSchedule', 'userUpdated'])
defineProps({
  titleProperty: {
    required: true,
    type: Array as () => string[]
  },
  data: {
    required: true,
    type: Array as () => any[]
  },
  tableName: {
    required: true,
    type: String
  },
  typeTable: {
    required: true,
    type: String
  }
})
const deleteUser = async (id: number) => {
  try {
    await fetchData(`${apiUrl}/api/users/${id}`, 'DELETE')

    emit('itemDeleted', id)
  } catch (error) {
    console.error('error', error)
  }
}

/**
 * Update User
 */
const openUpdateModal = (userData: User) => {
  userToUpdate.value = { ...userData }
  isModalOpen.value = true
}
const updateUser = async (id: number) => {
  if (!userToUpdate.value) {
    console.error('No user to update')
    return
  }

  try {
    const userData = { user: userToUpdate.value }
    await fetchData(`${apiUrl}/api/users/${id}`, 'PUT', userData)
    emit('userUpdated', id)

    isModalOpen.value = false
  } catch (error) {
    console.error('error', error)
  }
}
</script>

<style scoped></style>
