<template>
    <h2 class="text-center">My Team(s)</h2>
    <section v-for="teamNameData in teamsNameData">
        <h3 class="text-center">{{ teamNameData.name }}</h3>
        <table class="w-full text-center">
            <thead>
                <tr>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Role</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="userTeamData in usersTeamData">
                    <td>{{ userTeamData.username }}</td>
                    <td>{{ userTeamData.email }}</td>
                    <td>{{ userTeamData.role }}</td>
                </tr>
            </tbody>
        </table>
    </section>

</template>
  
<script lang="ts" setup>
import { onMounted, ref, watch } from 'vue';
import { apiUrl } from '../constants/urls'
import { User } from '../models/Users';

const teamsNameData = ref<TeamInterface[]>([])
const usersTeamData = ref<User[]>([])
const userId = localStorage.getItem('userID')
const getTeamsofUser = async () => {
    try{
        const response = await fetch(`${apiUrl}/api/teams/${userId}/team`)
        const data = await response.json()
        if(data){
            teamsNameData.value = data
        }
    }
    catch(error){
        console.error("An error occured while the fetching of the data")
    }
}
const getUserByTeam = async (teamId :number) => {
    try{
        const response = await fetch(`${apiUrl}/api/users/team/${teamId}`)
        const data = await response.json()
        if(data){
            usersTeamData.value = data
        }
    }
    catch(error){
        console.error("An error occured while the fetching of the data")
    }
}
onMounted(async () => {
    getTeamsofUser()
    
});

watch(() => teamsNameData.value, (newVal: TeamInterface[]) => {
    newVal.forEach(team => {
        getUserByTeam(team.id)
    })
})

export interface TeamInterface{
    id: number
    name: string
}

</script>
  
<style scoped></style>
  