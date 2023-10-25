<template>
    <div class="p-2 flex flex-col items-center">
        <h1 class="text-3xl font-bold underline">Profil</h1>
        <div class="w-full max-w-md">
            <div><strong>Username:</strong> {{ user.username }}</div>
            <div><strong>Email:</strong> {{ user.email }}</div>
            <div><strong>Role:</strong> {{ user.role }}</div>
            <div v-if="user.team"><strong>Team:</strong> {{ user.team.name }}</div>
            <button v-if="canDelete" @click="deleteAccount" class="bg-red-600 text-white px-4 py-2 mt-4">Delete
                Account</button>
        </div>
    </div>
</template>

<script lang="ts">
import { ref, onMounted, computed, onBeforeMount } from 'vue';
import { useRoute, useRouter } from 'vue-router';

export default {
    name: 'Profil',
    setup() {
        const route = useRoute();
        const router = useRouter();
        const user = ref({});

        const storedUserID = localStorage.getItem('userID') ? Number(localStorage.getItem('userID')) : null;
        const storedUserRole = localStorage.getItem('userRole');

        onBeforeMount(() => {
            if (!storedUserID) {
                router.push('/');
            }
        });

        const fetchProfile = async () => {
            const userId = route.params.userId;
            const API_URL = `${import.meta.env.VITE_API_URL}/api/users/${userId}`;
            const response = await fetch(API_URL);
            user.value = await response.json();
        };

        const deleteAccount = async () => {
            if (storedUserRole === 'general_manager' || storedUserID === user.value.id) {
                const API_URL = `${import.meta.env.VITE_API_URL}/api/users/${user.value.id}`;
                try {
                    const response = await fetch(API_URL, {
                        method: 'DELETE',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                    });

                    if (!response.ok) {
                        throw new Error('Failed to delete the profile');
                    }
                    if(storedUserID === user.value.id){
                        localStorage.removeItem('userID');
                        localStorage.removeItem('userRole');
                        router.push('/');
                    } else {
                        router.push(`/dashboard/${storedUserID}`);
                    }
                } catch (error) {
                    console.error('Error deleting profile:', error);
                }
            }
        };


        const canDelete = computed(() => {
            return storedUserRole === 'general_manager' || storedUserID === user.value.id;
        });

        onMounted(() => {
            fetchProfile();
        });

        return {
            user,
            deleteAccount,
            canDelete
        };
    }
}
</script>