<template>
  <div>
    <h2>{{ pageTitle }}</h2>

    <form @submit.prevent="handleSubmit">
      <input
        v-model="workingTimeDetails.startDate"
        type="date"
      >
      <input
        v-model="workingTimeDetails.startTime"
        type="time"
      >
      <input
        v-model="workingTimeDetails.endDate"
        type="date"
      >
      <input
        v-model="workingTimeDetails.endTime"
        type="time"
      >

      <button type="submit">
        {{ actionLabel }}
      </button>

      <template v-if="isEditMode">
        <button @click.prevent="deleteWorkingTime">
          Delete
        </button>
      </template>
    </form>

    <div
      v-if="showAlert"
      :class="alertClasses"
      role="alert"
    >
      <div class="flex">
        <div class="py-1">
          <svg
            class="fill-current h-6 w-6 text-teal-500 mr-4"
            :class="{ 'text-error': isDeleted }"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
          >
            <path
              d="M2.93 17.07A10 10 0 1 1 17.07 2.93 10 10 0 0 1 2.93 17.07zm12.73-1.41A8 8 0 1 0 4.34 4.34a8 8 0 0 0 11.32 11.32zM9 11V9h2v6H9v-4zm0-6h2v2H9V5z"
            />
          </svg>
        </div>
        <div>
          <p :class="alertTitleClass">
            {{ alertMessage }}
          </p>
          <p :class="alertTextClass">
            {{ alertSuccessMessage }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

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
const showAlert = computed(() => isCreated.value || isDeleted.value || isUpdated.value)

const alertClasses = computed(() => {
  return {
    'bg-teal-100': isCreated.value || isDeleted.value || isUpdated.value,
    'bg-red-100': isDeleted.value,
    'border-t-4': isCreated.value || isDeleted.value || isUpdated.value,
    'border-teal-500': isCreated.value || isUpdated.value,
    'border-error': isDeleted.value,
    'rounded-b': isCreated.value || isDeleted.value || isUpdated.value,
    'rounded-b-lg': isDeleted.value,
    'rounded-b-sm': isCreated.value || isUpdated.value,
    'text-teal-900': isCreated.value || isUpdated.value,
    'text-red-900': isDeleted.value,
    'px-4': isCreated.value || isDeleted.value || isUpdated.value,
    'py-3': isCreated.value || isDeleted.value || isUpdated.value,
    'shadow-md': isCreated.value || isDeleted.value || isUpdated.value
  }
})
const alertTitleClass = computed(() => {
  return isDeleted.value ? 'font-bold text-red-700' : 'font-bold text-teal-700'
})
const alertTextClass = computed(() => {
  return isDeleted.value ? 'text-sm text-red-600' : 'text-sm text-teal-600'
})

onMounted(() => {
  if (route.params.workingTimeId) {
    isEditMode.value = true
    loadWorkingTimeDetails()
  }
})

const getUserInfo = async () => {
  try {
    const storedUserID = sessionStorage.getItem('userID');
    const userId = route.params.userId.toString();

    const currentUser = await fetchData(`${apiUrl}/api/users/${storedUserID}`);
    const targetUser = await fetchData(`${apiUrl}/api/users/${userId}`);

    return {
      currentUser,
      targetUser
    };
  } catch (error) {
    console.error('Error fetching user information:', error);
    return { currentUser: null, targetUser: null };
  }
};

const loadWorkingTimeDetails = async () => {
  try {
    const userId = route.params.userId;
    const workingTimeId = route.params.workingTimeId;

    const data = await fetchData(`${apiUrl}/api/workingtimes/${userId}/${workingTimeId}`);

    const start = new Date(data.start);
    const end = new Date(data.end);

    workingTimeDetails.value.startDate = start.toISOString().split('T')[0];
    workingTimeDetails.value.startTime = start.toTimeString().slice(0, 5);
    workingTimeDetails.value.endDate = end.toISOString().split('T')[0];
    workingTimeDetails.value.endTime = end.toTimeString().slice(0, 5);
  } catch (error) {
    console.error('Error :', error)
  }
};

const handleSubmit = () => {
  if (isEditMode.value) {
    updateWorkingTime()
  } else {
    createWorkingTime()
  }
}

const createWorkingTime = async () => {
  try {
    const { currentUser, targetUser } = await getUserInfo();
    const isAuthorized =
      (currentUser.role === 'employee' && currentUser.id === targetUser.id) ||
      (currentUser.role === 'manager' && currentUser.team.id === targetUser.team.id);

    if (!isAuthorized) {
      console.error('Unauthorized: You do not have permission to create this working time');
      return;
    }

    const startDateTime = `${new Date(`${workingTimeDetails.value.startDate}T${workingTimeDetails.value.startTime}`).toISOString().slice(0, -5)}Z`;
    const endDateTime = `${new Date(`${workingTimeDetails.value.endDate}T${workingTimeDetails.value.endTime}`).toISOString().slice(0, -5)}Z`;

    if (new Date(endDateTime) < new Date(startDateTime)) {
      console.error('Cannot create a working time that ends in the past');
      return;
    }

    await fetchData(`${apiUrl}/api/workingtimes/${targetUser.id}`, 'POST', {
      workingtime: {
        start: startDateTime,
        end: endDateTime,
      },
    });

    isCreated.value = true;
    alertMessage.value = 'WorkingTime created';
    alertSuccessMessage.value = 'Working hours have been successfully created.';
    workingTimeDetails.value = { startDate: '', endDate: '', startTime: '', endTime: '' };
  } catch (error) {
    console.error('Error :', error)
  }
};

const updateWorkingTime = async () => {
  try {
    const workingTimeId = route.params.workingTimeId;
    const { currentUser, targetUser } = await getUserInfo();
    const isAuthorized =
      (currentUser.role === 'employee' && currentUser.id === targetUser.id) ||
      (currentUser.role === 'manager' && currentUser.team.id === targetUser.team.id);

    if (!isAuthorized) {
      console.error('Unauthorized: You do not have permission to update this working time');
      return;
    }

    const startDateTime = `${new Date(`${workingTimeDetails.value.startDate}T${workingTimeDetails.value.startTime}`).toISOString().slice(0, -5)}Z`;
    const endDateTime = `${new Date(`${workingTimeDetails.value.endDate}T${workingTimeDetails.value.endTime}`).toISOString().slice(0, -5)}Z`;

    if (new Date(endDateTime) < new Date(startDateTime)) {
      console.error('Cannot update a working time that ends in the past');
      return;
    }

    await fetchData(`${apiUrl}/api/workingtimes/${workingTimeId}`, 'PUT', {
      workingtime: {
        start: startDateTime,
        end: endDateTime,
        user_id: targetUser.id
      }
    });

    isUpdated.value = true;
    alertMessage.value = 'WorkingTime updated';
    alertSuccessMessage.value = 'Working hours have been successfully updated.';
  } catch (error) {
    console.error('Error :', error)
  }
};

const deleteWorkingTime = async () => {
  try {
    const workingTimeId = route.params.workingTimeId;
    const { currentUser, targetUser } = await getUserInfo();
    const isAuthorized =
      (currentUser.role === 'employee' && currentUser.id === targetUser.id) ||
      (currentUser.role === 'manager' && currentUser.team.id === targetUser.team.id);

    if (!isAuthorized) {
      console.error('Unauthorized: You do not have permission to delete this working time');
      return;
    }

    await fetchData(`${apiUrl}/api/workingtimes/${workingTimeId}`, 'DELETE');

    isDeleted.value = true;
    alertMessage.value = 'WorkingTime deleted';
    alertSuccessMessage.value = 'Working hours have been successfully deleted.';
    workingTimeDetails.value = { startDate: '', endDate: '', startTime: '', endTime: '' };
  } catch (error) {
    console.error('Error :', error)
  }
};

</script>