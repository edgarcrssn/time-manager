<template>
  <table class="table-auto border-collapse border border-black min-w-full text-center">
    <thead>
      <tr>
        <th class="border border-black" v-for="thName in titleProperty">{{ thName }}</th>
      </tr>
    </thead>
    <tbody>
      <tr v-if="typeTable == 'user'" v-for="(donnee, id) in data">
        <td class="border border-black">{{ donnee.username }}</td>
        <td class="border border-black">test@gmail.com</td>
        <td class="border border-black">
          <button type="button" @click="deleteUser(id)" class="mr-3"><img alt="delete" src="../../icon/delete_icon.png" class="w-5 h-5 float-left"/></button>
          <button type="button" @click="updateUser(id)" class="ml-3"><img alt="update" src="../../icon/update_icon.png" class="w-5 h-5 float-left"/></button>
        </td>
      </tr>

      <tr v-if="typeTable == 'team'" v-for="(donnee, id) in data">
        <td class="border border-black">{{ donnee.name }}</td>
        <td class="border border-black">
          <button type="button" @click="deleteUser(id)" class="mr-3"><img alt="delete" src="../../icon/delete_icon.png" class="w-5 h-5 float-left"/></button>
          <button type="button" @click="updateUser(id)" class="ml-3"><img alt="update" src="../../icon/update_icon.png" class="w-5 h-5 float-left"/></button>
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
  setup: function(){
    const updateUser = (id: number) => {
      //convert id to integer
      console.log(`update user ${id}`)
    }

    const deleteUser = (id: number) => {
      console.log(`id de l'utilisateur ${id}`);
    };
    return {
      updateUser,
      deleteUser
    }
  }
}
</script>


<style scoped>

</style>