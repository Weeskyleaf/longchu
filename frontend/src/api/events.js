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

export function addEventTask(eventId, data) {
  return request.post('/tasks', { ...data, event_id: eventId })
}

export function addEventTag(eventId, data) {
  return request.post('/tags/bindEvent', { ...data, event_id: eventId })
}

export function getTagDict(params) {
  return request.get('/tags/dict', { params })
}
