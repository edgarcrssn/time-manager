import { createRouter, createWebHistory } from 'vue-router'
import Index from './pages/index.vue'
import ChartManager from './components/ChartManager.vue'
import ClockManager from './components/ClockManager.vue'
import WorkingTime from './components/WorkingTime.vue'
import Dashboard from './pages/dashboard.vue'
import Profile from './pages/profile.vue'
import WorkingTimes from './pages/working-times.vue'
import DashboardLayout from './layouts/DashboardLayout.vue'
import UserComponentVue from './components/UserComponent.vue';

const routes = [
  { path: '/', component: Index },
  {
    path: '/dashboard',
    component: DashboardLayout,
    children: [
      {
        path: ':userId',
        name: 'Dashboard',
        component: Dashboard
      },
      {
        path: 'chartManager/:userId',
        name: 'ChartManager',
        component: ChartManager,
        props: true
      },
      {
        path: 'clock/:userId',
        name: 'ClockManager',
        component: ClockManager,
        props: true
      },
      {
        path: 'profile/:userId',
        name: 'Profile',
        component: Profile
      },
      {
        path: 'working-times/:userId',
        name: 'WorkingTimes',
        component: WorkingTimes
      },
      {
        path: '/workingTime/:userId',
        name: 'CreateWorkingTime',
        component: WorkingTime,
        props: true
      },
      {
        path: '/workingTime/:userId/:workingTimeId',
        name: 'EditWorkingTime',
        component: WorkingTime,
        props: true
      },
      {
        path: '/workingTime/:userId/:workingTimeId',
        name: 'DeleteWorkingTime',
        component: WorkingTime,
        props: true
      }
      {
        path: '/view-users',
        name: 'View-users',
        component: UserComponentVue
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
