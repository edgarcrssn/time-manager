<template>
  <div v-if="isOpen" class="fixed inset-0 flex items-center justify-center">
    <div class="modal-bg absolute inset-0 bg-gray-500 opacity-75"></div>
    <div class="modal-content bg-white p-8 rounded shadow-lg z-50">
      <h2 class="text-2xl font-semibold mb-4">Créer un utilisateur</h2>
      <form @submit.prevent="createUser">
        <div class="mb-4">
          <label for="username" class="block text-sm font-medium text-gray-600">Nom d'utilisateur</label>
          <input type="text" id="username" v-model="userInput.username" class="mt-1 p-2 w-full border rounded">
        </div>
        <div class="mb-4">
          <label for="email" class="block text-sm font-medium text-gray-600">Adresse email</label>
          <input type="email" id="email" v-model="userInput.email" class="mt-1 p-2 w-full border rounded">
        </div>
        <button type="submit" class="bg-blue-500 text-white p-2 rounded hover:bg-blue-700">Créer</button>
      </form>
      <button @click="closeModal" class="mt-4 text-gray-600">Fermer</button>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref } from 'vue'
const props = defineProps({
  isOpen:{
    required: true,
    type: Boolean
  }
})
const emit = defineEmits(['close','addItem'])
 //to get the data in the form
const userInput = ref({
  username: '',
  email: ''
})

const closeModal = () => {
  emit('close')
}

const createUser = () => {
  if(props.isOpen){
    var myHeaders = new Headers();
    myHeaders.append("Content-Type","application/json")
    var raw = JSON.stringify({
      "user":{
        "username": `${userInput.value.username}`,
        "email": `${userInput.value.email}`
      }
    });
    const requestOptions: RequestInit = {
      method: 'POST',
      body: raw,
      headers: myHeaders,
      redirect: 'follow'
    }
    fetch(`${import.meta.env.VITE_API_URL}/api/users`, requestOptions)
    .then((response: Response) => {
      if(response.ok){
        emit('addItem')
          closeModal()
        }
      })
    .catch((error: Error) => console.error(error))    
  }
}
</script>

<style scoped>

</style>
