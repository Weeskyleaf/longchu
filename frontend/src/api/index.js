import axios from 'axios'
import { ElMessage } from 'element-plus'

const request = axios.create({
  baseURL: '/api',
  timeout: 15000,
})

request.interceptors.request.use(
  (config) => config,
  (error) => Promise.reject(error)
)

request.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const msg =
      error.response?.data?.message ||
      error.response?.data?.error ||
      error.message ||
      '请求失败'
    ElMessage.error(msg)
    return Promise.reject(error)
  }
)

export default request
