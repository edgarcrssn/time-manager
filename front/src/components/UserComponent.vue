<script lang="ts">
import {onMounted, ref} from "vue";
import TableComponent from "./table/TableComponent.vue";
import UserModal from "./pop-up/PopUp.vue";
export default {
    props: {

    },
    data() {
        return {
            refreshKey: 0
        }
    },
    methods: {
        reloadComponent(){
            this.refreshKey += 1
        }
    },
    setup: function () {
        const userId = localStorage.getItem('userID');
        const getUserUrl = `${import.meta.env.VITE_API_URL}/api/users/${userId}`;
        const userUsername = ref("");
        const userEmail = ref("");
        const usersData = ref([] as any[]);
        const isManager = ref(false);

        const isOpenModal = ref(false);

        const openModal = () => {
            isOpenModal.value = true;
        };

        const closeModal = () => {
            isOpenModal.value = false;
        };


        const getUser = async () => {
            try {
                const response = await fetch(getUserUrl);
                const data = await response.json();
                if (data) {
                    if (data.role === "manager" || data.role === "general_manager") {
                        isManager.value = true;
                        // get all the users of the database
                        try{
                            const getAllUsersUrl = `${import.meta.env.VITE_API_URL}/api/users`
                            const responseAllUsers = await fetch(getAllUsersUrl)
                            const dataUsers = await responseAllUsers.json();
                            if(dataUsers){
                                usersData.value = dataUsers
                            }
                        }
                        catch(error){
                            console.error("Error while fetching all the users data")
                        }
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

        const handleItemDeleted = (itemId: number) => {
            usersData.value = usersData.value.filter(user => user.id !== itemId);
        };
        const handleItemAdded = async () => {
            try{
                const getAllUsersUrl = `${import.meta.env.VITE_API_URL}/api/users`
                const responseAllUsers = await fetch(getAllUsersUrl)
                const dataUsers = await responseAllUsers.json();
                if(dataUsers){
                    usersData.value = dataUsers
                }
            }
            catch(error){
                console.error("Error while fetching all the users data")
            }
        };
        return {
            userUsername,
            userEmail,
            isManager,
            usersData,
            createUser,
            handleItemDeleted,
            handleItemAdded,
            isOpenModal,
            openModal,
            closeModal
        };
    },
    components: { TableComponent, UserModal }
};
</script>

<template>
  <meta charset="UTF-8">
  <h1 class="text-center text-4xl">Manage user</h1>
  <button @click="openModal" class="bg-blue-500 text-white p-2 rounded hover:bg-blue-700">
    Add User
  </button>

  <user-modal :is-open="isOpenModal" @close="closeModal"></user-modal>


  <h2 class="text-center" v-if="isManager && usersData.length > 0">Table of the users</h2>
  <TableComponent :titleProperty="['Username','Email', 'Actions']"
  :data="usersData" :tableName="'Table of Users'" :typeTable="'user'" v-if="isManager" :key="refreshKey" @itemDeleted="handleItemDeleted" @addItem="handleItemAdded" ></TableComponent>
</template>

<style scoped>

</style>