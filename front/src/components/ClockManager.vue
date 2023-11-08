<template>
  <section class="text-center bg-white border rounded-3xl p-4 w-full">
    <h2>Work Tracking</h2>
    <UserClock :user-id="userId" />
  </section>
</template>

<script lang="ts" setup>
import { defineProps } from 'vue'
import 'mosha-vue-toastify/dist/style.css'
import UserClock from './UserClock.vue'

const { userId } = defineProps({
  userId: {
    type: Number,
    required: true
  }
})
</script>
