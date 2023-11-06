<template>
  <section class="p-2 flex flex-col items-center">
    <h2>Working times</h2>
    <article class="w-full max-w-md">
      <TableComponent
        :data="workingTimes"
        :title-property="['ID', 'Start Time', 'End Time', 'User ID']"
        table-name="Working Times Table"
        type-table="workingTimes"
      />
    </article>
  </section>
</template>

<script lang="ts" setup>
import { ref, onMounted, onBeforeMount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import TableComponent from '../components/table/TableComponent.vue'
import { apiUrl } from '../constants/urls'
import { fetchData } from '../services/httpService'

const route = useRoute()
const router = useRouter()

const routeParamUserId = route.params.userId

const storedUserID = sessionStorage.getItem('userID') ? Number(sessionStorage.getItem('userID')) : null
const storedUserRole = sessionStorage.getItem('userRole')

const workingTimes = ref([])

onBeforeMount(() => {
  if (!storedUserID) {
    router.push('/')
  }
  if (+routeParamUserId !== storedUserID && storedUserRole !== 'general_manager') {
    router.push(`/dashboard/${storedUserID}`)
  }
})

const getWorkingTimes = async () => {
  const API_URL = `${apiUrl}/api/workingtimes/${routeParamUserId}`
  try {
    const data = await fetchData(API_URL)
    workingTimes.value = data
  } catch (error: unknown) {
    if (error instanceof Error && error.message.includes('404')) {
      router.push(`/dashboard/${storedUserID}`)
      return
    }
    console.error('Error fetching working times:', error)
  }
}

onMounted(() => {
  getWorkingTimes()
})
</script>