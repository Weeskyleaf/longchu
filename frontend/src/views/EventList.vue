<template>
  <div class="event-list-page">
    <!-- 顶部标题栏 -->
    <div class="top-header">
      <span class="top-header__title">核电人因事件分析数据库系统 · 事件台账模块</span>
      <div class="top-header__actions">
        <el-button @click="handleExportSummary">
          <el-icon><Download /></el-icon>导出汇总表
        </el-button>
        <el-button @click="$router.push('/statistics')">
          <el-icon><DataAnalysis /></el-icon>全局统计图
        </el-button>
        <el-button type="primary" @click="$router.push('/events/create')">
          <el-icon><Plus /></el-icon>新增事件
        </el-button>
      </div>
    </div>

    <!-- 统计卡片行 -->
    <el-row :gutter="16" class="summary-row">
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-card__value primary">{{ stats.total ?? '--' }}</div>
          <div class="summary-card__label">事件总量</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-card__value warning">{{ stats.pending ?? '--' }}</div>
          <div class="summary-card__label">待审核事件</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-card__value danger">{{ stats.highRisk ?? '--' }}</div>
          <div class="summary-card__label">高风险事件</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-card__value success">{{ stats.completeness ?? '--' }}%</div>
          <div class="summary-card__label">完整度</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 检索与筛选 -->
    <el-card shadow="never" class="filter-card">
      <div class="filter-card__header">
        <span class="filter-card__title">检索与筛选</span>
        <span class="filter-card__subtitle">支持按时间、机组、系统、事件类型、标签状态等条件组合检索</span>
      </div>
      <el-form :model="searchForm" label-width="80px" class="filter-form">
        <el-row :gutter="16">
          <el-col :span="6">
            <el-form-item label="关键词">
              <el-input v-model="searchForm.keyword" placeholder="事件标题/编号/关键描述" clearable>
                <template #prefix><el-icon><Search /></el-icon></template>
              </el-input>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="事件类型">
              <el-select v-model="searchForm.event_type" placeholder="全部" clearable style="width: 100%">
                <el-option label="设备故障" value="设备故障" />
                <el-option label="人因失误" value="人因失误" />
                <el-option label="程序缺陷" value="程序缺陷" />
                <el-option label="组织因素" value="组织因素" />
                <el-option label="外部事件" value="外部事件" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="任务阶段">
              <el-select v-model="searchForm.task_phase" placeholder="全部" clearable style="width: 100%">
                <el-option label="全部" value="" />
                <el-option label="事故前" value="事故前" />
                <el-option label="事故后" value="事故后" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="审核状态">
              <el-select v-model="searchForm.audit_status" placeholder="全部" clearable style="width: 100%">
                <el-option label="全部" value="" />
                <el-option label="待审核" value="待审核" />
                <el-option label="已审核" value="已审核" />
                <el-option label="已归档" value="已归档" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="6">
            <el-form-item label="电厂/机组">
              <el-select v-model="searchForm.unit_no" placeholder="全部" clearable style="width: 100%">
                <el-option label="1号机组" value="1" />
                <el-option label="2号机组" value="2" />
                <el-option label="3号机组" value="3" />
                <el-option label="4号机组" value="4" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="所属系统">
              <el-select v-model="searchForm.system_code" placeholder="全部" clearable style="width: 100%">
                <el-option label="反应堆冷却剂系统" value="RCS" />
                <el-option label="化学和容积控制系统" value="CVCS" />
                <el-option label="安全注入系统" value="SIS" />
                <el-option label="余热排出系统" value="RHRS" />
                <el-option label="电气系统" value="ELS" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="5">
            <el-form-item label="开始日期">
              <el-date-picker
                v-model="searchForm.start_date"
                type="date"
                placeholder="选择日期"
                value-format="YYYY-MM-DD"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="5">
            <el-form-item label="结束日期">
              <el-date-picker
                v-model="searchForm.end_date"
                type="date"
                placeholder="选择日期"
                value-format="YYYY-MM-DD"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="2" class="filter-actions">
            <el-button @click="handleReset">重置条件</el-button>
            <el-button type="primary" @click="handleSearch">
              <el-icon><Search /></el-icon>执行检索
            </el-button>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <!-- 主内容：双栏布局 -->
    <div class="main-columns">
      <!-- 左栏：事件台账列表 -->
      <el-card shadow="never" class="list-panel">
        <div class="panel-header">
          <div>
            <span class="panel-title">事件台账列表</span>
            <span class="panel-subtitle">已按发生时间倒序排列展示</span>
          </div>
        </div>
        <el-table
          :data="tableData"
          v-loading="loading"
          highlight-current-row
          @current-change="handleRowSelect"
          style="width: 100%"
          :row-class-name="tableRowClass"
        >
          <el-table-column prop="event_no" label="事件编号" width="130">
            <template #default="{ row }">
              <span class="event-no-link">{{ row.event_no }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="event_title" label="事件名称/简述" min-width="180" show-overflow-tooltip>
            <template #default="{ row }">
              <div>{{ row.event_title }}</div>
              <el-progress
                :percentage="row.completeness ?? 0"
                :stroke-width="4"
                :color="completenessColor(row.completeness)"
                :show-text="false"
                style="margin-top: 4px"
              />
            </template>
          </el-table-column>
          <el-table-column prop="event_type" label="事件类型" width="100">
            <template #default="{ row }">
              <el-tag :type="typeTagMap[row.event_type] || 'info'" size="small" effect="light">
                {{ row.event_type }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="task_phase" label="任务阶段" width="90" align="center">
            <template #default="{ row }">
              <span>{{ row.task_phase || '--' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="unit_no" label="电厂/机组" width="90" align="center">
            <template #default="{ row }">
              <span>{{ row.unit_no ? `${row.unit_no}号机组` : '--' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="occur_time" label="发生时间" width="110" />
        </el-table>
        <div class="pagination-bar">
          <el-pagination
            :current-page="pagination.page"
            :page-size="pagination.pageSize"
            :page-sizes="[10, 20, 50]"
            :total="pagination.total"
            layout="total, sizes, prev, pager, next"
            small
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>

      <!-- 右栏：事件详情预览 -->
      <el-card shadow="never" class="preview-panel">
        <div class="panel-header">
          <span class="panel-title">事件详情预览</span>
        </div>
        <div v-if="selectedEvent" class="preview-content">
          <h3 class="preview-event-title">{{ selectedEvent.event_title }}</h3>
          <div class="preview-event-no">{{ selectedEvent.event_no }}</div>
          <el-divider />
          <div class="preview-field">
            <span class="preview-label">事件类型</span>
            <el-tag :type="typeTagMap[selectedEvent.event_type] || 'info'" size="small">
              {{ selectedEvent.event_type }}
            </el-tag>
          </div>
          <div class="preview-field">
            <span class="preview-label">任务阶段</span>
            <span class="preview-value">{{ selectedEvent.task_phase || '--' }}</span>
          </div>
          <div class="preview-field">
            <span class="preview-label">机组信息</span>
            <span class="preview-value">{{ selectedEvent.unit_no ? `${selectedEvent.unit_no}号机组` : '--' }}</span>
          </div>
          <div class="preview-field">
            <span class="preview-label">发生时间</span>
            <span class="preview-value">{{ selectedEvent.occur_time }}</span>
          </div>
          <div class="preview-field">
            <span class="preview-label">后果等级</span>
            <el-tag :type="consequenceColor(selectedEvent.consequence_level)" size="small">
              {{ selectedEvent.consequence_level || '--' }}
            </el-tag>
          </div>
          <el-divider />
          <div class="preview-desc-label">事件描述</div>
          <p class="preview-desc">{{ selectedEvent.event_summary || '暂无描述信息' }}</p>
          <el-button
            type="primary"
            style="width: 100%; margin-top: 16px"
            @click="$router.push(`/events/${selectedEvent.id}`)"
          >查看完整详情</el-button>
        </div>
        <el-empty v-else description="点击左侧列表行预览事件信息" :image-size="80" />
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Plus, Search, Download, DataAnalysis } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getEvents, getEventStats } from '../api/events'

const loading = ref(false)
const tableData = ref([])
const selectedEvent = ref(null)

const stats = reactive({
  total: null,
  pending: null,
  highRisk: null,
  completeness: null
})

const searchForm = reactive({
  keyword: '',
  event_type: '',
  task_phase: '',
  audit_status: '',
  unit_no: '',
  system_code: '',
  start_date: '',
  end_date: ''
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

function completenessColor(val) {
  if (val >= 80) return '#67c23a'
  if (val >= 50) return '#e6a23c'
  return '#f56c6c'
}

function tableRowClass({ row }) {
  return selectedEvent.value?.id === row.id ? 'selected-row' : ''
}

async function fetchStats() {
  try {
    const res = await getEventStats()
    Object.assign(stats, {
      total: res.data?.total ?? 0,
      pending: res.data?.pending ?? 0,
      highRisk: res.data?.highRisk ?? 0,
      completeness: res.data?.completeness ?? 0
    })
  } catch { /* keep defaults */ }
}

async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: pagination.page - 1,
      size: pagination.pageSize,
      keyword: searchForm.keyword || undefined,
      event_type: searchForm.event_type || undefined,
      task_phase: searchForm.task_phase || undefined,
      audit_status: searchForm.audit_status || undefined,
      unit_no: searchForm.unit_no || undefined,
      system_code: searchForm.system_code || undefined,
      start_date: searchForm.start_date || undefined,
      end_date: searchForm.end_date || undefined
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
  selectedEvent.value = null
  fetchData()
}

function handleReset() {
  Object.assign(searchForm, {
    keyword: '', event_type: '', task_phase: '', audit_status: '',
    unit_no: '', system_code: '', start_date: '', end_date: ''
  })
  handleSearch()
}

function handleSizeChange() {
  pagination.page = 1
  fetchData()
}

function handleCurrentChange() {
  fetchData()
}

function handleRowSelect(row) {
  selectedEvent.value = row
}

function handleExportSummary() {
  ElMessage.success('汇总表导出功能开发中')
}

onMounted(() => {
  fetchData()
  fetchStats()
})
</script>

<style scoped>
.event-list-page {
  background: #f5f7fa;
  min-height: 100%;
}

/* ---- 顶部标题栏 ---- */
.top-header {
  background: #1a365d;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 24px;
  border-radius: 8px;
  margin-bottom: 16px;
}
.top-header__title {
  font-size: 17px;
  font-weight: 600;
  letter-spacing: 1px;
}
.top-header__actions {
  display: flex;
  gap: 10px;
}

/* ---- 统计卡片 ---- */
.summary-row {
  margin-bottom: 16px;
}
.summary-card {
  border-radius: 8px;
  text-align: center;
  padding: 8px 0;
}
.summary-card :deep(.el-card__body) {
  padding: 18px 12px;
}
.summary-card__value {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.2;
}
.summary-card__value.primary { color: #409eff; }
.summary-card__value.warning { color: #e6a23c; }
.summary-card__value.danger  { color: #f56c6c; }
.summary-card__value.success { color: #67c23a; }
.summary-card__label {
  font-size: 13px;
  color: #909399;
  margin-top: 6px;
}

/* ---- 筛选区域 ---- */
.filter-card {
  border-radius: 8px;
  margin-bottom: 16px;
}
.filter-card :deep(.el-card__body) {
  padding: 20px 24px 8px;
}
.filter-card__header {
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #ebeef5;
}
.filter-card__title {
  font-size: 15px;
  font-weight: 600;
  color: #1a365d;
}
.filter-card__subtitle {
  font-size: 12px;
  color: #909399;
  margin-left: 12px;
}
.filter-form :deep(.el-form-item) {
  margin-bottom: 14px;
}
.filter-actions {
  display: flex;
  align-items: flex-start;
  padding-top: 30px;
  gap: 8px;
  min-width: 200px;
}

/* ---- 主双栏布局 ---- */
.main-columns {
  display: flex;
  gap: 16px;
}
.list-panel {
  flex: 65;
  border-radius: 8px;
  min-width: 0;
}
.preview-panel {
  flex: 35;
  border-radius: 8px;
  min-width: 0;
}
.list-panel :deep(.el-card__body),
.preview-panel :deep(.el-card__body) {
  padding: 16px 20px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
  padding-bottom: 10px;
  border-bottom: 1px solid #ebeef5;
}
.panel-title {
  font-size: 15px;
  font-weight: 600;
  color: #1a365d;
}
.panel-subtitle {
  font-size: 12px;
  color: #909399;
  margin-left: 10px;
}

/* ---- 表格 ---- */
.event-no-link {
  color: #409eff;
  font-weight: 500;
}
:deep(.el-table) {
  border-radius: 6px;
}
:deep(.el-table .selected-row td) {
  background-color: #ecf5ff !important;
}
:deep(.el-table__row) {
  cursor: pointer;
}

.pagination-bar {
  display: flex;
  justify-content: flex-end;
  margin-top: 14px;
}

/* ---- 预览面板 ---- */
.preview-content {
  padding: 4px 0;
}
.preview-event-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  line-height: 1.4;
}
.preview-event-no {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}
.preview-field {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px dashed #ebeef5;
}
.preview-label {
  font-size: 13px;
  color: #909399;
  flex-shrink: 0;
}
.preview-value {
  font-size: 13px;
  color: #303133;
  text-align: right;
}
.preview-desc-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 6px;
}
.preview-desc {
  font-size: 13px;
  color: #606266;
  line-height: 1.7;
  display: -webkit-box;
  -webkit-line-clamp: 5;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
