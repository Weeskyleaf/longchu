import request from './index'
import axios from 'axios'

const sparhRequest = axios.create({
  baseURL: '/spar-h/api',
  timeout: 30000,
})

sparhRequest.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const msg = error.response?.data?.error || error.message || '计算服务请求失败'
    import('element-plus').then(({ ElMessage }) => ElMessage.error(msg))
    return Promise.reject(error)
  }
)

export function getCases(params) {
  return request.get('/analysis/cases', { params })
}

export function getCase(id) {
  return request.get(`/analysis/cases/${id}`)
}

export function createCase(data) {
  return request.post('/analysis/cases', data)
}

export function updateCase(id, data) {
  return request.put(`/analysis/cases/${id}`, data)
}

export function deleteCase(id) {
  return request.delete(`/analysis/cases/${id}`)
}

export function calculateCase(id) {
  return request.post(`/analysis/cases/${id}/calculate`)
}

export function getPsfDict(params) {
  return request.get('/analysis/psf-dict', { params })
}

export function addCaseTask(caseId, data) {
  return request.post(`/analysis/cases/${caseId}/tasks`, data)
}

export function addDependency(caseId, data) {
  return request.post(`/analysis/cases/${caseId}/dependency`, data)
}

export function sparhCalc(data) {
  return sparhRequest.post('/calculate', data)
}

export function sparhSaveCase(data) {
  return request.post('/analysis/cases/from-calc', data)
}
