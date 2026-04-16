import axios from 'axios'
import request from './index'

export function getCases(params) {
  return request.get('/analysis/cases', { params })
}

export function getCase(id) {
  return request.get(`/analysis/cases/${id}`)
}

export function createCase(data) {
  return request.post('/analysis/cases', data)
}

export function deleteCase(id) {
  return request.delete(`/analysis/cases/${id}`)
}

export function calculateCase(id) {
  return request.post(`/analysis/cases/${id}/calculate`)
}

export function getPsfDict() {
  return request.get('/analysis/psf-dict')
}

export function addCaseTask(caseId, data) {
  return request.post(`/analysis/cases/${caseId}/tasks`, data)
}

export function addDependency(caseId, data) {
  return request.post(`/analysis/cases/${caseId}/dependency`, data)
}

const sparhAxios = axios.create({
  baseURL: 'http://localhost:5001/api/spar-h',
  timeout: 30000
})

export function sparhCalc(data) {
  return sparhAxios.post('/calculate', data).then(res => res.data)
}
