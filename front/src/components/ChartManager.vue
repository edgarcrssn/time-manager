<template>
    <section>
        <h2 class="text-3xl mt-4 mb-4">User {{ userId }}'s Charts</h2>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 p-4">
            <div>
                <BarChart :data="barChartData" :options="chartOptions" />
            </div>
            <div>
                <PieChart :data="pieChartData" :options="chartOptions" />
            </div>
            <div>
                <LineChart :data="lineChartData" :options="chartOptions" />
            </div>
        </div>
    </section>
</template>
  
<script lang="ts">
import BarChart from './charts/BarChart.vue';
import PieChart from './charts/PieChart.vue';
import LineChart from './charts/LineChart.vue';

export default {
    name: 'ChartManager',
    components: {
        BarChart,
        PieChart,
        LineChart
    },
    props: {
        userId: {
            type: String,
            required: true
        }
    },
    data() {
        return {
            barChartData: {
                labels: ['January', 'February', 'March'],
                datasets: [{ data: [40, 20, 12] }]
            },
            pieChartData: {
                labels: ['Red', 'Blue', 'Yellow'],
                datasets: [{ data: [300, 50, 100] }]
            },
            lineChartData: {
                labels: ['January', 'February', 'March'],
                datasets: [{ data: [65, 59, 80] }]
            },
            chartOptions: {
                responsive: true,
                maintainAspectRatio: false
            }
        }
    }
}
</script>