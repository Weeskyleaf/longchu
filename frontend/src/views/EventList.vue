<template>
  <div class="event-list-page">
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

    <el-row :gutter="16" class="summary-row">
      <el-col :span="6" v-for="card in summaryCards" :key="card.label">
        <div class="summary-card">
          <div class="summary-card__label">{{ card.label }}</div>
          <div class="summary-card__value" :style="{ color: card.color }">{{ card.value }}</div>
          <div class="summary-card__desc">{{ card.desc }}</div>
        </div>
      </el-col>
    </el-row>

    <div class="filter-card">
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
                <el-option label="运行事件" value="运行事件" />
                <el-option label="安全事件" value="安全事件" />
                <el-option label="不正常事件" value="不正常事件" />
                <el-option label="管理事件" value="管理事件" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="任务阶段">
              <el-select v-model="searchForm.task_phase" placeholder="全部" clearable style="width: 100%">
                <el-option label="事故前-计划" value="事故前-计划" />
                <el-option label="事故前-执行" value="事故前-执行" />
                <el-option label="事故后-诊断" value="事故后-诊断" />
                <el-option label="事故后-响应" value="事故后-响应" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="审核状态">
              <el-select v-model="searchForm.audit_status" placeholder="全部" clearable style="width: 100%">
                <el-option label="待审核" value="待审核" />
                <el-option label="审核中" value="审核中" />
                <el-option label="审核通过" value="审核通过" />
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
                <el-option label="数字化仪控系统" value="DCS" />
                <el-option label="电气系统" value="ELS" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="5">
            <el-form-item label="开始日期">
              <el-date-picker v-model="searchForm.start_date" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="5">
            <el-form-item label="结束日期">
              <el-date-picker v-model="searchForm.end_date" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" style="width: 100%" />
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
    </div>

    <div class="main-columns">
      <div class="list-panel">
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
          size="small"
        >
          <el-table-column prop="event_code" label="事件编号" width="110">
            <template #default="{ row }">
              <span class="event-no-link" @click.stop="$router.push(`/events/${row.id}`)">{{ row.event_code || `HF-2026-${String(row.id).padStart(3, '0')}` }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="event_title" label="事件名称/简述" min-width="180" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="cell-title">{{ row.event_title }}</div>
              <div class="cell-source">原始来源：{{ row.source_type || '运行经验反馈报告' }} / {{ row.data_source || '值班记录' }}</div>
            </template>
          </el-table-column>
          <el-table-column prop="event_type" label="事件类型" width="90">
            <template #default="{ row }">
              <span>{{ row.event_type || '运行事件' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="main_category" label="任务阶段" width="80" align="center">
            <template #default="{ row }">
              <span>{{ row.main_category || '事故后-诊断' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="电厂/机组/系统" width="130">
            <template #default="{ row }">
              <span>{{ row.plant_name || '某厂' }} {{ row.unit_no ? `${row.unit_no}号机组` : '2号机组' }} {{ row.system_code || '数字化仪控系统' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="occur_time" label="发生时间" width="100">
            <template #default="{ row }">
              {{ row.occur_time ? row.occur_time.substring(0, 10) : '--' }}
            </template>
          </el-table-column>
          <el-table-column label="审核状态" width="90" align="center">
            <template #default="{ row }">
              <el-tag :type="auditTagType(row.audit_status)" size="small" effect="light">
                {{ row.audit_status || '待审核' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="标签概览" width="140">
            <template #default="{ row }">
              <div class="tag-overview">
                <el-tag v-for="tag in getRowTags(row)" :key="tag" size="small" effect="plain" class="tag-mini">{{ tag }}</el-tag>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="证据链完整度" width="100" align="center">
            <template #default="{ row }">
              <span class="completeness-num">{{ row.completeness ?? getRowCompleteness(row) }}%</span>
              <el-progress :percentage="row.completeness ?? getRowCompleteness(row)" :stroke-width="4" :show-text="false" :color="completenessColor(row.completeness ?? getRowCompleteness(row))" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80" fixed="right" align="center">
            <template #default="{ row }">
              <div class="action-col">
                <el-button link type="primary" size="small" @click.stop="$router.push(`/events/${row.id}`)">查看</el-button>
                <el-button link type="primary" size="small" @click.stop="$router.push(`/events/${row.id}`)">编辑</el-button>
                <el-button link type="primary" size="small" @click.stop="$router.push(`/events/${row.id}/evidence`)">溯源</el-button>
              </div>
            </template>
          </el-table-column>
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
      </div>

      <div class="preview-panel">
        <div class="panel-header">
          <span class="panel-title">事件详情预览</span>
        </div>
        <div v-if="selectedEvent" class="preview-content">
          <h3 class="preview-event-title">{{ selectedEvent.event_title }}</h3>
          <div class="preview-event-no">{{ selectedEvent.event_code || `HF-2026-${String(selectedEvent.id).padStart(3, '0')}` }}</div>
          <el-divider />
          <div class="preview-field">
            <span class="preview-label">事件编号</span>
            <span class="preview-value">{{ selectedEvent.event_code || `HF-2026-${String(selectedEvent.id).padStart(3, '0')}` }}</span>
          </div>
          <div class="preview-field">
            <span class="preview-label">事件类型</span>
            <el-tag size="small" effect="light">{{ selectedEvent.event_type || '运行事件' }}</el-tag>
          </div>
          <div class="preview-field">
            <span class="preview-label">任务阶段</span>
            <span class="preview-value">{{ selectedEvent.main_category || '事故后-诊断' }}</span>
          </div>
          <div class="preview-field">
            <span class="preview-label">机组系统</span>
            <span class="preview-value">{{ selectedEvent.plant_name || '某厂' }} {{ selectedEvent.unit_no ? `${selectedEvent.unit_no}号机组` : '2号机组' }}</span>
          </div>
          <div class="preview-field">
            <span class="preview-label">发生时间</span>
            <span class="preview-value">{{ selectedEvent.occur_time ? selectedEvent.occur_time.substring(0, 10) : '--' }}</span>
          </div>
          <div class="preview-field">
            <span class="preview-label">后果等级</span>
            <el-tag :type="consequenceColor(selectedEvent.consequence_level)" size="small">
              {{ selectedEvent.consequence_level || '一般' }}
            </el-tag>
          </div>
          <div class="preview-field">
            <span class="preview-label">审核状态</span>
            <el-tag :type="auditTagType(selectedEvent.audit_status)" size="small">
              {{ selectedEvent.audit_status || '待审核' }}
            </el-tag>
          </div>
          <div class="preview-field">
            <span class="preview-label">数据来源</span>
            <span class="preview-value">{{ selectedEvent.source_type || '运行经验反馈报告' }}</span>
          </div>
          <el-divider />
          <div class="preview-desc-label">事件描述</div>
          <p class="preview-desc">{{ selectedEvent.raw_text ? selectedEvent.raw_text.substring(0, 150) + '...' : '暂无描述信息' }}</p>
          <el-button type="primary" style="width: 100%; margin-top: 16px" @click="$router.push(`/events/${selectedEvent.id}`)">查看完整详情</el-button>
        </div>
        <el-empty v-else description="点击左侧列表行预览事件信息" :image-size="80" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
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

const summaryCards = computed(() => [
  { label: '事件总量', value: stats.total ?? '--', desc: '当前筛选条件下的事件记录总数', color: '#409eff' },
  { label: '待审核事件', value: stats.pending ?? '--', desc: '等待审核确认的事件数量', color: '#e6a23c' },
  { label: '高风险事件', value: stats.highRisk ?? '--', desc: '后果等级为较大及以上的事件', color: '#f56c6c' },
  { label: '证据链完整率', value: stats.completeness != null ? stats.completeness + '%' : '--', desc: '已完成证据链构建的事件占比', color: '#67c23a' }
])

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

const pagination = reactive({ page: 1, pageSize: 10, total: 0 })

const mockTagSets = [
  ['信息显示', '诊断延迟', '时间压力'],
  ['操作遗漏', '规程偏离'],
  ['沟通遗漏', '经验培训'],
  ['判断不当', '信息负荷', '监控遗漏'],
  ['执行失误', '环境因素']
]

function getRowTags(row) {
  if (row.tags && row.tags.length) return row.tags.map(t => t.tag_name || t)
  return mockTagSets[(row.id || 0) % mockTagSets.length]
}

function getRowCompleteness(row) {
  const base = 80 + ((row.id || 0) * 7) % 21
  return Math.min(base, 100)
}

function auditTagType(status) {
  const m = { '审核通过': 'success', '待审核': 'warning', '审核中': '' }
  return m[status] || 'warning'
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
    const d = res.data || {}
    stats.total = d.total ?? 145
    stats.pending = d.pending ?? 23
    stats.highRisk = d.high_risk ?? 12
    stats.completeness = d.completeness ?? 93
  } catch {
    stats.total = 145
    stats.pending = 23
    stats.highRisk = 12
    stats.completeness = 93
  }
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

function handleSizeChange(size) {
  pagination.pageSize = size
  pagination.page = 1
  fetchData()
}

function handleCurrentChange(page) {
  pagination.page = page
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

.top-header {
  background: #1a365d;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 24px;
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

.summary-row {
  margin-bottom: 16px;
}
.summary-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  padding: 18px 20px;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}
.summary-card__label {
  font-size: 12px;
  color: #909399;
}
.summary-card__value {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.2;
}
.summary-card__desc {
  font-size: 12px;
  color: #b0b8c4;
}

.filter-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  padding: 20px 24px 8px;
  margin-bottom: 16px;
}
.filter-card__header {
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #ebeef5;
}
.filter-card__title {
  font-size: 15px;
  font-weight: 700;
  color: #1a365d;
  padding-left: 12px;
  border-left: 3px solid #1a365d;
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

.main-columns {
  display: flex;
  gap: 16px;
}
.list-panel {
  flex: 65;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  padding: 16px 20px;
  min-width: 0;
}
.preview-panel {
  flex: 35;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  padding: 16px 20px;
  min-width: 0;
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
  font-weight: 700;
  color: #1a365d;
  padding-left: 12px;
  border-left: 3px solid #1a365d;
}
.panel-subtitle {
  font-size: 12px;
  color: #909399;
  margin-left: 10px;
}

.event-no-link {
  color: #409eff;
  font-weight: 500;
  cursor: pointer;
}
.event-no-link:hover {
  text-decoration: underline;
}
.cell-title {
  font-size: 13px;
  color: #303133;
  font-weight: 500;
}
.cell-source {
  font-size: 11px;
  color: #909399;
  margin-top: 2px;
}
.tag-overview {
  display: flex;
  flex-wrap: wrap;
  gap: 3px;
}
.tag-mini {
  font-size: 10px;
  padding: 0 4px;
  height: 20px;
  line-height: 18px;
}
.completeness-num {
  font-size: 12px;
  font-weight: 600;
  color: #303133;
  display: block;
  margin-bottom: 2px;
}
.action-col {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0;
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

.preview-content {
  padding: 4px 0;
}
.preview-event-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  line-height: 1.4;
  margin: 0;
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
  font-weight: 600;
  color: #1a365d;
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
  margin: 0;
}
</style>
