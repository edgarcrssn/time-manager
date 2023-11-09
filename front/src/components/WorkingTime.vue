<template>
  <div>
    <h2>{{ pageTitle }}</h2>

    <form @submit.prevent="handleSubmit">
      <input v-model="workingTimeDetails.startDate" type="date">
      <input v-model="workingTimeDetails.startTime" type="time">
      <input v-model="workingTimeDetails.endDate" type="date">
      <input v-model="workingTimeDetails.endTime" type="time">

      <button type="submit">
        {{ actionLabel }}
      </button>

      <template v-if="isEditMode">
        <button @click.prevent="deleteWorkingTime">
          Delete
        </button>
      </template>
    </form>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'
import { createToast } from 'mosha-vue-toastify'
import 'mosha-vue-toastify/dist/style.css'

const route = useRoute()

const alertMessage = ref('')
const alertSuccessMessage = ref('')
const isCreated = ref(false)
const isEditMode = ref(false)
const isDeleted = ref(false)
const isUpdated = ref(false)
const workingTimeDetails = ref({
  endDate: '',
  endTime: '',
  startDate: '',
  startTime: ''
})

const pageTitle = computed(() => (isEditMode.value ? 'Update this Working Time' : 'Add a Working Time'))
const actionLabel = computed(() => (isEditMode.value ? 'Update' : 'Add'))

onMounted(() => {
  if (route.params.workingTimeId) {
    isEditMode.value = true
    loadWorkingTimeDetails()
  }
})

const getUserInfo = async () => {
  try {
    const storedUserID = sessionStorage.getItem('userID')
    const userId = route.params.userId.toString()

    const currentUser = await fetchData(`${apiUrl}/api/users/${storedUserID}`)
    const targetUser = await fetchData(`${apiUrl}/api/users/${userId}`)

    return {
      currentUser,
      targetUser
    }
  } catch (error) {
    createToast(
      { title: 'An error occurred while the fetching of the data of the user' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error fetching user information:', error)
    return { currentUser: null, targetUser: null }
  }
}

const loadWorkingTimeDetails = async () => {
  try {
    const userId = route.params.userId
    const workingTimeId = route.params.workingTimeId

    const data = await fetchData(`${apiUrl}/api/workingtimes/${userId}/${workingTimeId}`)

    const start = new Date(data.start)
    const end = new Date(data.end)

    workingTimeDetails.value.startDate = start.toISOString().split('T')[0]
    workingTimeDetails.value.startTime = start.toTimeString().slice(0, 5)
    workingTimeDetails.value.endDate = end.toISOString().split('T')[0]
    workingTimeDetails.value.endTime = end.toTimeString().slice(0, 5)
  } catch (error) {
    createToast(
      { title: 'An error occurred while the loading of the details of the workingtime' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error :', error)
  }
}

const handleSubmit = () => {
  if (isEditMode.value) {
    updateWorkingTime()
  } else {
    createWorkingTime()
  }
}

const createWorkingTime = async () => {
  try {
    const { currentUser, targetUser } = await getUserInfo()
    const isAuthorized =
      (currentUser.role === 'employee' && currentUser.id === targetUser.id) ||
      (currentUser.role === 'manager' && currentUser.team.id === targetUser.team.id) ||
      currentUser.role === 'general_manager'

    if (!isAuthorized) {
      createToast(
        { title: 'An error occurred because, you are not authorized' },
        { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
      )
      console.error('Unauthorized: You do not have permission to create this working time')
      return
    }

    const startDateTime = `${new Date(`${workingTimeDetails.value.startDate}T${workingTimeDetails.value.startTime}`)
      .toISOString()
      .slice(0, -5)}Z`
    const endDateTime = `${new Date(`${workingTimeDetails.value.endDate}T${workingTimeDetails.value.endTime}`)
      .toISOString()
      .slice(0, -5)}Z`

    if (new Date(endDateTime) < new Date(startDateTime)) {
      createToast(
        { title: 'An error occurred because the workingtime ends in the past' },
        { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
      )
      console.error('Cannot create a working time that ends in the past')
      return
    }

    await fetchData(`${apiUrl}/api/workingtimes/${targetUser.id}`, 'POST', {
      workingtime: {
        start: startDateTime,
        end: endDateTime
      }
    })

    isCreated.value = true
    alertMessage.value = 'WorkingTime created'
    alertSuccessMessage.value = 'Working hours have been successfully created.'
    workingTimeDetails.value = { startDate: '', endDate: '', startTime: '', endTime: '' }

    createToast(
      { title: 'The working time has been created with success.' },
      { transition: 'zoom', timeout: 8000, type: 'success', position: 'bottom-right' }
    )
  } catch (error) {
    createToast(
      { title: 'An error occurred while the creation of the workingtime' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error :', error)
  }
}

const updateWorkingTime = async () => {
  try {
    const workingTimeId = route.params.workingTimeId
    const { currentUser, targetUser } = await getUserInfo()
    const isAuthorized =
      (currentUser.role === 'employee' && currentUser.id === targetUser.id) ||
      (currentUser.role === 'manager' && currentUser.team.id === targetUser.team.id)

    if (!isAuthorized) {
      createToast(
        { title: 'An error occurred because you are not authorized' },
        { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
      )
      console.error('Unauthorized: You do not have permission to update this working time')
      return
    }

    const startDateTime = `${new Date(`${workingTimeDetails.value.startDate}T${workingTimeDetails.value.startTime}`)
      .toISOString()
      .slice(0, -5)}Z`
    const endDateTime = `${new Date(`${workingTimeDetails.value.endDate}T${workingTimeDetails.value.endTime}`)
      .toISOString()
      .slice(0, -5)}Z`

    if (new Date(endDateTime) < new Date(startDateTime)) {
      createToast(
        { title: 'An error occurred because the workingtime ends in the past' },
        { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
      )
      console.error('Cannot update a working time that ends in the past')
      return
    }

    await fetchData(`${apiUrl}/api/workingtimes/${workingTimeId}`, 'PUT', {
      workingtime: {
        start: startDateTime,
        end: endDateTime,
        user_id: targetUser.id
      }
    })

    isUpdated.value = true
    alertMessage.value = 'WorkingTime updated'
    alertSuccessMessage.value = 'Working hours have been successfully updated.'
  } catch (error) {
    createToast(
      { title: 'An error occurred while the updating of the workingtime' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error :', error)
  }
}

const deleteWorkingTime = async () => {
  try {
    const workingTimeId = route.params.workingTimeId
    const { currentUser, targetUser } = await getUserInfo()
    const isAuthorized =
      (currentUser.role === 'employee' && currentUser.id === targetUser.id) ||
      (currentUser.role === 'manager' && currentUser.team.id === targetUser.team.id)

    if (!isAuthorized) {
      createToast(
        { title: 'An error occurred because you are not authorized' },
        { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
      )
      console.error('Unauthorized: You do not have permission to delete this working time')
      return
    }

    await fetchData(`${apiUrl}/api/workingtimes/${workingTimeId}`, 'DELETE')

    isDeleted.value = true
    alertMessage.value = 'WorkingTime deleted'
    alertSuccessMessage.value = 'Working hours have been successfully deleted.'
    workingTimeDetails.value = { startDate: '', endDate: '', startTime: '', endTime: '' }
  } catch (error) {
    createToast(
      { title: 'An error occurred while the deleting of the workingtime' },
      { transition: 'zoom', timeout: 8000, type: 'danger', position: 'bottom-right' }
    )
    console.error('Error :', error)
  }
}
</script>
