import { createRouter, createWebHistory } from 'vue-router'
import Index from './pages/index.vue'
import ChartManager from './components/ChartManager.vue';
import ClockManager from './components/ClockManager.vue';

const routes = [
  { path: '/', component: Index },
  {
    path: '/chartManager/:userId',
    name: 'ChartManager',
    component: ChartManager,
    props: true
  },
  {
    path: '/clock/:userId',
    name: 'ClockManager',
    component: ClockManager,
    props: true
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
