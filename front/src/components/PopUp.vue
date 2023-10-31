<template>
  <div v-if="isOpen" class="fixed inset-0 flex items-center justify-center">
    <div class="modal-bg absolute inset-0 bg-gray-500 opacity-75"></div>
    <div class="modal-content bg-white p-8 rounded shadow-lg z-50">
      <h3>{{ title }}</h3>
      <slot></slot>
    </div>
  </div>
</template>

<script lang="ts" setup>
const props = defineProps({
  isOpen: {
    required: true,
    type: Boolean
  },
  title: {
    type: String,
    default: ''
  }
})
</script>

<style scoped></style>
