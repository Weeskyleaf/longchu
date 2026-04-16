import request from './index'

export function getEvents(params) {
  return request.get('/events', { params })
}

export function getEvent(id) {
  return request.get(`/events/${id}`)
}

export function createEvent(data) {
  return request.post('/events', data)
}

export function updateEvent(id, data) {
  return request.put(`/events/${id}`, data)
}

export function deleteEvent(id) {
  return request.delete(`/events/${id}`)
}

export function getEventStats() {
  return request.get('/events/stats/overview')
}

export function addTask(eventId, data) {
  return request.post(`/events/${eventId}/tasks`, data)
}

export function addTag(eventId, data) {
  return request.post(`/events/${eventId}/tags`, data)
}
