import { createRouter, createWebHistory } from 'vue-router'
import Index from './pages/index.vue'
import ChartManager from './components/ChartManager.vue';
import ClockManager from './components/ClockManager.vue';
import Dashboard from './pages/dashboard.vue';
import Profile from './pages/profile.vue';

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
  },
  {
    path: '/dashboard/:userId',
    name: 'Dashboard',
    component: Dashboard
  },
  {
    path: '/profile/:userId',
    name: 'Profile',
    component: Profile,
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
