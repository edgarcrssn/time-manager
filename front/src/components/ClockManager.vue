<template>
    <div class="text-center">
        <h2 class="text-3xl mt-4 mb-4">Work Tracking</h2>
        <p>{{ clockIn ? 'Work started at: ' + startDateTime + ' 🧠' : 'Rest 😴' }}</p>
        <button class="text-white bg-slate-300 rounded-xl p-2 mt-4" @click="clock">{{ clockIn ? 'Clock Out' : 'Clock In'
        }}</button>
    </div>
</template>

<script lang="ts">
import { ref, onMounted } from 'vue';

export default {
    props: {
        userId: {
            type: String,
            required: true
        }
    },
    setup(props) {
        const startDateTime = ref(null);
        const clockIn = ref(false);
        const API_URL = `http://localhost:4000/api/clocks/${props.userId}`;

        const refresh = async () => {
            try {
                const response = await fetch(API_URL);
                const data = await response.json();
                if (data && data.length > 0) {
                    const lastClock = data[0];
                    clockIn.value = lastClock.status;
                    startDateTime.value = lastClock.status ? new Date().toLocaleString() : null;
                }
            } catch (error) {
                console.error('Error fetching clock status:', error);
            }
        };

        const clock = async () => {
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        clock: {
                            time: new Date().toISOString()
                        }
                    })
                });

                const data = await response.json();
                clockIn.value = data.status;
                startDateTime.value = data.status ? new Date().toLocaleString() : null;
            } catch (error) {
                console.error('Error clocking in:', error);
            }
        };


        onMounted(() => {
            refresh();
        });

        return {
            startDateTime,
            clockIn,
            refresh,
            clock
        };
    }
};
</script>
