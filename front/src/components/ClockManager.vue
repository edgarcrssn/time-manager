<template>
  <section class="text-center card p-4 w-full">
    <h3>Work Tracking</h3>
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
