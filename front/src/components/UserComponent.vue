<script lang="ts">
import {onMounted, ref} from "vue";
import TableComponent from "./table/TableComponent.vue";
export default {
    props: {},
    setup: function () {
        const userId = localStorage.getItem('userID');
        const getUserUrl = `${import.meta.env.VITE_API_URL}/api/users/${userId}`;
        //const getTeams = `${import.meta.env.VITE_API_URL}/api/teams`;
        const userUsername = ref("");
        const userEmail = ref("");
        const isManager = ref(false);
        //const teams = ref([])
        const getUser = async () => {
            try {
                const response = await fetch(getUserUrl);
                const data = await response.json();
                if (data) {
                    userUsername.value = data.username;
                    userEmail.value = data.email;
                    console.log(data);
                    if (data.role === "manager" || data.role === "general_manager") {
                        isManager.value = true;
                        // get the data from the api of the users in the same team of the manager
                        //todo create component for the table 
                    }
                }
            }
            catch (error) {
                console.error(error);
            }
        };
        onMounted(async () => {
            getUser();
        });
        const createUser = () => {
            console.log("create user");
        };
        return {
            userUsername,
            userEmail,
            isManager,
            createUser
        };
    },
    components: { TableComponent }
};
</script>

<template>
  <meta charset="UTF-8">
  <h1 class="text-center text-4xl">Manage user</h1>
  <h2>My informations</h2>
  <p>My username : {{userUsername}}</p>
  <p>My Email : {{userEmail}}</p>
  <button type="button" @click="createUser()">Add User</button>
  <h2 class="text-center" v-if="isManager">Table of the users</h2>
  <TableComponent :titleProperty="['Username','Email']"
  :data="[]" :tableName="'Table of Users'" :typeTable="'user'" v-if="isManager">

  </TableComponent>

  <h2 class="text-center" v-if="isManager">Table of the team</h2>
  <TableComponent :titleProperty="['Team Name']"
  :data="[]" :tableName="'Table of Teams'" :typeTable="'team'" v-if="isManager">

  </TableComponent>
</template>

<style scoped>

</style>