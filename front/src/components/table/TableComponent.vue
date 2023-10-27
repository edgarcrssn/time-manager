<template>
  <table class="table-auto border-collapse border border-black min-w-full text-center">
    <thead>
      <tr>
        <th class="border border-black" v-for="thName in titleProperty">{{ thName }}</th>
      </tr>
    </thead>
    <tbody>
      <tr v-if="typeTable == 'user'" v-for="donnee in data">
        <td class="border border-black">{{ donnee.username }}</td>
        <td class="border border-black">{{ donnee.email }}</td>
        <td class="border border-black">
          <button type="button" @click="deleteUser(donnee.id)" class="mr-3"><img alt="delete" src="../../../icon/delete_icon.png" class="w-5 h-5 float-left"/></button>
        </td>
      </tr>

      <tr v-if="typeTable == 'team'" v-for="(donnee, id) in data">
        <td class="border border-black">{{ donnee.name }}</td>
        <td class="border border-black">
          <button type="button" @click="deleteUser(id)" class="mr-3"><img alt="delete" src="../../../icon/delete_icon.png" class="w-5 h-5 float-left"/></button>
        </td>
      </tr>
      
    </tbody>
  </table>
</template>

<script lang="ts">

export default {
  props: {
    titleProperty:{
        required: true,
        type: Array as () => string[]
    },
    data:{
        required: true,
        type: Array as () => any[]
    },
    tableName:{
        required: true,
        type: String
    },
    typeTable:{
      required: true,
      type: String
    }
  },
  methods: {
    deleteUser(id: number){
      const requestOptions: RequestInit = {
        method: 'DELETE',
        redirect: 'follow'
      };
      fetch(`${import.meta.env.VITE_API_URL}/api/users/${id}`, requestOptions)
      .then((response: Response) => {
        if(response.ok){
          this.$emit('itemDeleted', id);
        }
      })
      .catch((error: Error) => console.error('error', error))
    },
  },
  
}
</script>


<style scoped>

</style>