import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/', redirect: '/events' },
  {
    path: '/events',
    name: 'EventList',
    component: () => import('../views/EventList.vue'),
    meta: { title: '事件台账', group: '人因事件分析' }
  },
  {
    path: '/events/create',
    name: 'EventCreate',
    component: () => import('../views/EventCreate.vue'),
    meta: { title: '新增事件', group: '人因事件分析' }
  },
  {
    path: '/events/:id',
    name: 'EventDetail',
    component: () => import('../views/EventDetail.vue'),
    meta: { title: '事件详情', group: '人因事件分析' }
  },
  {
    path: '/statistics',
    name: 'Statistics',
    component: () => import('../views/Statistics.vue'),
    meta: { title: '统计分析', group: '人因事件分析' }
  },
  {
    path: '/analysis',
    name: 'AnalysisList',
    component: () => import('../views/AnalysisList.vue'),
    meta: { title: '分析案例', group: '人因可靠性分析' }
  },
  {
    path: '/analysis/create',
    name: 'AnalysisCreate',
    component: () => import('../views/AnalysisCreate.vue'),
    meta: { title: '新建案例', group: '人因可靠性分析' }
  },
  {
    path: '/analysis/:id',
    name: 'AnalysisDetail',
    component: () => import('../views/AnalysisDetail.vue'),
    meta: { title: '案例详情', group: '人因可靠性分析' }
  },
  {
    path: '/sparh-calc',
    name: 'SparhCalculator',
    component: () => import('../views/SparhCalculator.vue'),
    meta: { title: 'SPAR-H计算', group: '人因可靠性分析' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
