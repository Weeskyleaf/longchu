import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/', redirect: '/events' },
  {
    path: '/events',
    name: 'EventList',
    component: () => import('../views/events/EventList.vue'),
  },
  {
    path: '/events/create',
    name: 'EventCreate',
    component: () => import('../views/events/EventCreate.vue'),
  },
  {
    path: '/events/:id',
    name: 'EventDetail',
    component: () => import('../views/events/EventDetail.vue'),
  },
  {
    path: '/statistics',
    name: 'Statistics',
    component: () => import('../views/statistics/Statistics.vue'),
  },
  {
    path: '/analysis',
    name: 'AnalysisList',
    component: () => import('../views/analysis/AnalysisList.vue'),
  },
  {
    path: '/analysis/create',
    name: 'AnalysisCreate',
    component: () => import('../views/analysis/AnalysisCreate.vue'),
  },
  {
    path: '/analysis/:id',
    name: 'AnalysisDetail',
    component: () => import('../views/analysis/AnalysisDetail.vue'),
  },
  {
    path: '/sparh-calc',
    name: 'SparhCalculator',
    component: () => import('../views/analysis/SparhCalculator.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
