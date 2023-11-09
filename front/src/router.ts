import { createRouter, createWebHistory } from 'vue-router'
import Index from './pages/index.vue'
import ChartManager from './components/ChartManager.vue'
import ClockManager from './components/ClockManager.vue'
import WorkingTime from './components/WorkingTime.vue'
import Dashboard from './pages/dashboard.vue'
import Profile from './pages/profile.vue'
import WorkingTimes from './pages/working-times.vue'
import DashboardLayout from './layouts/DashboardLayout.vue'
import UserComponentVue from './components/UserComponent.vue'
import FoireAuxQuestions from './components/FoireAuxQuestions.vue'
import TeamsComponent from './components/TeamsComponent.vue'

const routes = [
  { path: '/', component: Index },
  {
    path: '/faq',
    name: 'FoireAuxQuestions',
    component: FoireAuxQuestions
  },
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
        path: 'chart-manager/:userId',
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
        path: 'working-time/:userId',
        name: 'CreateWorkingTime',
        component: WorkingTime,
        props: true
      },
      {
        path: 'working-time/:userId/:workingTimeId',
        name: 'EditWorkingTime',
        component: WorkingTime,
        props: true
      },
      {
        path: 'working-time/:userId/:workingTimeId',
        name: 'DeleteWorkingTime',
        component: WorkingTime,
        props: true
      },
      {
        path: 'view-users',
        name: 'View-users',
        component: UserComponentVue
      },
      {
        path: 'teams',
        name: 'teams',
        component: TeamsComponent
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
