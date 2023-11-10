<template>
  <MyTeamsManagement :my-id="+myId" />
</template>

<script lang="ts" setup>
import { useRouter } from 'vue-router'
import MyTeamsManagement from '../components/MyTeamsManagement.vue'

const router = useRouter()

const myId = sessionStorage.getItem('userID') || 0
if (!myId) router.push('/')
</script>

<style scoped></style>
