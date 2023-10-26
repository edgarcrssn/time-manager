<template>
    <div class="p-2 flex flex-col items-center">
        <h1 class="text-3xl font-bold underline">Time Manager</h1>

        <ClockManager :userId="userId" />
        <ChartManager :userId="userId" />
    </div>
</template>

<script lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import ClockManager from '../components/ClockManager.vue';
import ChartManager from '../components/ChartManager.vue';

export default {
    name: 'Dashboard',
    components: {
        ChartManager,
        ClockManager,
    },
    setup() {
        const route = useRoute();
        const router = useRouter();
        const userId = ref(route.params.userId);
        const username = ref('');

        const getUserInfo = async () => {
            try {
                const storedUserID = localStorage.getItem('userID');

                if (!storedUserID) {
                    router.push('/');
                    return;
                }

                // Fetching the details of the currently logged-in user
                const API_URL_CURRENT_USER = `${import.meta.env.VITE_API_URL}/api/users/${storedUserID}`;
                const responseCurrentUser = await fetch(API_URL_CURRENT_USER);
                const currentUser = await responseCurrentUser.json();

                // Fetching the details of the user whose dashboard is being accessed
                const API_URL = `${import.meta.env.VITE_API_URL}/api/users/${userId.value}`;
                const response = await fetch(API_URL);
                const user = await response.json();

                if (user && currentUser) {
                    username.value = user.username;

                    // If the logged-in user is an employee AND they're trying to access another user's dashboard
                    if (currentUser.role === "employee" && userId.value !== storedUserID) {
                        router.push(`/dashboard/${storedUserID}`);
                        return;
                    }

                    // If the logged-in user is a manager and they're trying to access a dashboard of an employee not in their team
                    if (currentUser.role === "manager" && currentUser.team?.id !== user.team?.id) {
                        router.push(`/dashboard/${storedUserID}`);
                        return;
                    }

                    // General manager can access all dashboards. No additional check is needed if the role is 'general_manager'.

                } else {
                    console.error('No user found for this ID');
                }
            } catch (error) {
                console.error('Error fetching user by ID:', error);
            }
        };

        onMounted(() => {
            getUserInfo();
        });

        return {
            userId,
            username
        };
    }
}
</script>
