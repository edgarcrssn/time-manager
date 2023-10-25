<template>
  <div>
    <router-view />
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { useRouter } from 'vue-router'

export default defineComponent({
  name: 'App',
  setup () {
    const router = useRouter()
    return { router }
  }
})
</script>
