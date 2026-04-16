<template>
  <div>
    <div class="page-header">
      <h2>事件台账</h2>
      <el-button type="primary" @click="$router.push('/events/create')">
        <el-icon><Plus /></el-icon> 新增事件
      </el-button>
    </div>

    <el-card shadow="never" class="search-card">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            style="width: 260px"
          />
        </el-form-item>
        <el-form-item label="事件类型">
          <el-select v-model="searchForm.event_type" placeholder="全部" clearable style="width: 140px">
            <el-option label="设备故障" value="设备故障" />
            <el-option label="人因失误" value="人因失误" />
            <el-option label="程序缺陷" value="程序缺陷" />
            <el-option label="组织因素" value="组织因素" />
            <el-option label="外部事件" value="外部事件" />
          </el-select>
        </el-form-item>
        <el-form-item label="机组">
          <el-input v-model="searchForm.unit_no" placeholder="机组号" clearable style="width: 100px" />
        </el-form-item>
        <el-form-item label="系统">
          <el-input v-model="searchForm.keyword" placeholder="系统/关键词" clearable style="width: 140px" />
        </el-form-item>
        <el-form-item label="标签状态">
          <el-select v-model="searchForm.tag_status" placeholder="全部" clearable style="width: 120px">
            <el-option label="已标注" value="已标注" />
            <el-option label="未标注" value="未标注" />
            <el-option label="待审核" value="待审核" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" style="margin-top: 16px">
      <el-table :data="tableData" v-loading="loading" stripe border style="width: 100%">
        <el-table-column prop="event_no" label="事件编号" width="140" />
        <el-table-column prop="event_title" label="事件标题" min-width="200" show-overflow-tooltip />
        <el-table-column prop="event_type" label="事件类型" width="110">
          <template #default="{ row }">
            <el-tag :type="typeTagMap[row.event_type] || 'info'" size="small">{{ row.event_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="main_category" label="主分类" width="100" />
        <el-table-column prop="unit_no" label="机组号" width="80" align="center" />
        <el-table-column prop="occur_time" label="发生时间" width="120" />
        <el-table-column prop="consequence_level" label="后果等级" width="100">
          <template #default="{ row }">
            <el-tag :type="consequenceColor(row.consequence_level)" size="small">{{ row.consequence_level }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="source_type" label="来源类型" width="100" />
        <el-table-column label="操作" width="260" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="$router.push(`/events/${row.id}`)">查看详情</el-button>
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="warning" size="small" @click="handleAudit(row)">审核</el-button>
            <el-button link type="success" size="small" @click="handleExport(row)">导出</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div style="display: flex; justify-content: flex-end; margin-top: 16px">
        <el-pagination
          :current-page="pagination.page"
          :page-size="pagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getEvents } from '../api/events'

const loading = ref(false)
const tableData = ref([])

const searchForm = reactive({
  dateRange: null,
  event_type: '',
  unit_no: '',
  keyword: '',
  tag_status: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

const typeTagMap = {
  '设备故障': 'danger',
  '人因失误': 'warning',
  '程序缺陷': '',
  '组织因素': 'info',
  '外部事件': 'success'
}

function consequenceColor(level) {
  const map = { '严重': 'danger', '较大': 'warning', '一般': 'info', '轻微': 'success' }
  return map[level] || 'info'
}

async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      pageSize: pagination.pageSize,
      event_type: searchForm.event_type || undefined,
      unit_no: searchForm.unit_no || undefined,
      keyword: searchForm.keyword || undefined,
      start_date: searchForm.dateRange?.[0] || undefined,
      end_date: searchForm.dateRange?.[1] || undefined
    }
    const res = await getEvents(params)
    tableData.value = res.data?.list || []
    pagination.total = res.data?.total || 0
  } catch {
    tableData.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  pagination.page = 1
  fetchData()
}

function handleReset() {
  searchForm.dateRange = null
  searchForm.event_type = ''
  searchForm.unit_no = ''
  searchForm.keyword = ''
  searchForm.tag_status = ''
  handleSearch()
}

function handleSizeChange(val) {
  pagination.pageSize = val
  pagination.page = 1
  fetchData()
}

function handleCurrentChange(val) {
  pagination.page = val
  fetchData()
}

function handleEdit(row) {
  ElMessage.info(`编辑事件: ${row.event_no}`)
}

function handleAudit(row) {
  ElMessage.info(`审核事件: ${row.event_no}`)
}

function handleExport(row) {
  ElMessage.success(`导出事件: ${row.event_no}`)
}

onMounted(fetchData)
</script>

<style scoped>
.search-card :deep(.el-card__body) {
  padding-bottom: 0;
}
</style>
