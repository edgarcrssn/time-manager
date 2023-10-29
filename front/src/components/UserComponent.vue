<template>
  <section>
    <h2 class="text-center text-4xl">
      Manage user
    </h2>
    <button
      class="bg-blue-500 text-white p-2 rounded hover:bg-blue-700"
      @click="openModal"
    >
      Add User
    </button>

    <user-modal
      :is-open="isOpenModal"
      @close="closeModal"
    />

    <h2
      v-if="isManager && usersData.length > 0"
      class="text-center"
    >
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
    />
  </section>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import TableComponent from './table/TableComponent.vue'
import UserModal from './PopUp.vue'

const refreshKey = ref(0)
const userId = localStorage.getItem('userID')
const getUserUrl = `${import.meta.env.VITE_API_URL}/api/users/${userId}`
const usersData = ref([])
const isManager = ref(false)
const isOpenModal = ref(false)

const openModal = () => {
  isOpenModal.value = true
}

const closeModal = () => {
  isOpenModal.value = false
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

const handleItemDeleted = (itemId) => {
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
