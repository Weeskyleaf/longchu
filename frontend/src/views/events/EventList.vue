<template>
  <div class="event-list">
    <el-card shadow="never" class="search-card">
      <el-form :model="query" inline>
        <el-form-item label="事件类型">
          <el-select v-model="query.event_type" placeholder="全部" clearable style="width: 150px">
            <el-option label="操作事件" value="操作事件" />
            <el-option label="设备事件" value="设备事件" />
            <el-option label="管理事件" value="管理事件" />
            <el-option label="组织事件" value="组织事件" />
          </el-select>
        </el-form-item>
        <el-form-item label="机组号">
          <el-input v-model="query.unit_no" placeholder="如 1号机组" clearable style="width: 140px" />
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="query.keyword" placeholder="搜索事件标题..." clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="query.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            style="width: 260px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">
            <el-icon><Search /></el-icon> 搜索
          </el-button>
          <el-button @click="resetQuery">
            <el-icon><Refresh /></el-icon> 重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" class="table-card">
      <template #header>
        <div class="card-header">
          <span class="card-title">事件台账</span>
          <el-button type="primary" @click="$router.push('/events/create')">
            <el-icon><Plus /></el-icon> 新增事件
          </el-button>
        </div>
      </template>

      <el-table :data="tableData" v-loading="loading" stripe border style="width: 100%">
        <el-table-column prop="event_code" label="事件编号" width="160" show-overflow-tooltip />
        <el-table-column prop="event_title" label="事件标题" min-width="200" show-overflow-tooltip />
        <el-table-column prop="event_type" label="事件类型" width="110" align="center">
          <template #default="{ row }">
            <el-tag :type="typeTagMap[row.event_type] || 'info'" size="small">{{ row.event_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="unit_no" label="机组号" width="100" align="center" />
        <el-table-column prop="occur_time" label="发生时间" width="170" align="center">
          <template #default="{ row }">
            {{ formatDate(row.occur_time) }}
          </template>
        </el-table-column>
        <el-table-column prop="consequence_level" label="后果等级" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="levelTagMap[row.consequence_level] || 'info'" size="small" v-if="row.consequence_level">
              {{ row.consequence_level }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="source_type" label="来源" width="100" align="center" />
        <el-table-column label="操作" width="220" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="$router.push(`/events/${row.id}`)">
              查看
            </el-button>
            <el-button type="warning" link size="small" @click="$router.push(`/events/create?id=${row.id}`)">
              编辑
            </el-button>
            <el-popconfirm title="确认删除该事件？" @confirm="handleDelete(row.id)">
              <template #reference>
                <el-button type="danger" link size="small">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          :current-page="pagination.page"
          :page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getEvents, deleteEvent } from '@/api/events'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const query = reactive({
  event_type: '',
  unit_no: '',
  keyword: '',
  dateRange: null,
})
const pagination = reactive({ page: 1, pageSize: 20, total: 0 })

const typeTagMap = { '操作事件': 'danger', '设备事件': 'warning', '管理事件': '', '组织事件': 'success' }
const levelTagMap = { '严重': 'danger', '较重': 'warning', '一般': 'info', '轻微': 'success' }

function formatDate(val) {
  if (!val) return ''
  return val.replace('T', ' ').substring(0, 16)
}

function resetQuery() {
  Object.assign(query, { event_type: '', unit_no: '', keyword: '', dateRange: null })
  pagination.page = 1
  fetchData()
}

function handleSizeChange(val) {
  pagination.pageSize = val
  pagination.page = 1
  fetchData()
}

function handlePageChange(val) {
  pagination.page = val
  fetchData()
}

async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      pageSize: pagination.pageSize,
      event_type: query.event_type || undefined,
      unit_no: query.unit_no || undefined,
      keyword: query.keyword || undefined,
      start_date: query.dateRange?.[0] || undefined,
      end_date: query.dateRange?.[1] || undefined,
    }
    const res = await getEvents(params)
    const d = res.data || res || {}
    tableData.value = Array.isArray(d) ? d : (d.list || [])
    pagination.total = d.total ?? tableData.value.length
  } catch {
    tableData.value = []
  } finally {
    loading.value = false
  }
}

async function handleDelete(id) {
  try {
    await deleteEvent(id)
    ElMessage.success('删除成功')
    fetchData()
  } catch { /* handled by interceptor */ }
}

onMounted(fetchData)
</script>

<style scoped>
.event-list { display: flex; flex-direction: column; gap: 16px; }
.search-card :deep(.el-card__body) { padding-bottom: 2px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.card-title { font-size: 16px; font-weight: 600; color: #303133; }
.pagination-wrap { display: flex; justify-content: flex-end; margin-top: 16px; }
</style>
