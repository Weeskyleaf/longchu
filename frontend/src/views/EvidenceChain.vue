<template>
  <div class="evidence-page" v-loading="loading">
    <!-- 顶部标签导航 -->
    <div class="tab-bar">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="证据链管理" name="evidence" />
        <el-tab-pane label="版本变更" name="version" disabled />
        <el-tab-pane label="审核细则" name="audit" disabled />
        <el-tab-pane label="站项关联" name="link" disabled />
        <el-tab-pane label="可审计" name="auditable" disabled />
      </el-tabs>
    </div>

    <!-- 标题栏 -->
    <div class="title-bar">
      <h2 class="page-title">证据链与追溯模块</h2>
      <div class="title-actions">
        <el-button @click="$router.push(`/events/${eventId}`)">返回事件模块</el-button>
        <el-button>导出证据总览</el-button>
        <el-button>查看版本变更</el-button>
        <el-button type="primary">新增证据</el-button>
      </div>
    </div>

    <!-- 信息卡片 -->
    <el-row :gutter="16" class="info-cards">
      <el-col :span="8">
        <div class="info-card">
          <span class="info-label">当前事件</span>
          <span class="info-value code">{{ eventData.event_no || '—' }}</span>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="info-card">
          <span class="info-label">证据总数</span>
          <span class="info-value">{{ evidenceList.length }}</span>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="info-card">
          <span class="info-label">当前版本</span>
          <span class="info-value">{{ currentVersion }}</span>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="info-cards" style="margin-top: 0">
      <el-col :span="8">
        <div class="info-card">
          <span class="info-label">证据完整度</span>
          <span class="info-value highlight">{{ completeness }}%</span>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="info-card">
          <span class="info-label">审核状态</span>
          <el-tag :type="auditStatusType" size="large" class="info-tag">{{ auditStatus }}</el-tag>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="info-card">
          <span class="info-label">最近操作</span>
          <span class="info-value small">{{ latestOperation }}</span>
        </div>
      </el-col>
    </el-row>

    <!-- 双栏主体 -->
    <el-row :gutter="20">
      <!-- 左栏：来源与证据登记 -->
      <el-col :span="12">
        <div class="panel">
          <div class="panel-head">
            <h3 class="section-title">来源与证据登记</h3>
            <p class="section-sub">对事件相关证据资料进行结构化登记与归档</p>
          </div>

          <el-form :model="form" label-width="110px" label-position="top" class="evidence-form">
            <el-form-item label="证据类型">
              <el-select v-model="form.evidenceType" placeholder="请选择证据类型" style="width: 100%">
                <el-option label="运维复盘记录" value="运维复盘记录" />
                <el-option label="操作规程文档" value="操作规程文档" />
                <el-option label="监控录像记录" value="监控录像记录" />
                <el-option label="访谈记录" value="访谈记录" />
                <el-option label="培训记录" value="培训记录" />
              </el-select>
            </el-form-item>

            <el-form-item label="文档编号">
              <el-input v-model="form.docNo" placeholder="请输入文档编号" />
            </el-form-item>

            <el-form-item label="文档标题">
              <el-input v-model="form.docTitle" placeholder="请输入文档标题" />
            </el-form-item>

            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="来源部门/负责部门">
                  <el-input v-model="form.department" placeholder="请输入部门" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="类型日期">
                  <el-date-picker
                    v-model="form.docDate"
                    type="date"
                    placeholder="选择日期"
                    style="width: 100%"
                    value-format="YYYY-MM-DD"
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="关联事件编号">
                  <el-input v-model="form.relatedEventNo" placeholder="关联事件编号" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="审核状态">
                  <el-select v-model="form.auditStatus" placeholder="选择状态" style="width: 100%">
                    <el-option label="待审核" value="待审核" />
                    <el-option label="审核中" value="审核中" />
                    <el-option label="已审核" value="已审核" />
                    <el-option label="已归档" value="已归档" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="证据内容">
              <el-input
                v-model="form.content"
                type="textarea"
                :rows="5"
                placeholder="请输入证据详细内容描述..."
              />
            </el-form-item>

            <div class="form-actions">
              <el-button @click="resetForm">重置</el-button>
              <el-button type="primary">保存证据</el-button>
            </div>
          </el-form>
        </div>
      </el-col>

      <!-- 右栏：追溯完整度评估 -->
      <el-col :span="12">
        <div class="panel">
          <div class="panel-head">
            <h3 class="section-title">追溯完整度评估</h3>
            <p class="section-sub">各维度证据链完整性校验结果</p>
          </div>

          <div class="progress-list">
            <div v-for="item in progressItems" :key="item.label" class="progress-item">
              <div class="progress-top">
                <span class="progress-label">{{ item.label }}</span>
                <span class="progress-pct">{{ item.pct }}%</span>
              </div>
              <el-progress
                :percentage="item.pct"
                :stroke-width="14"
                :show-text="false"
                :color="item.pct >= 100 ? '#10b981' : item.pct >= 60 ? '#f59e0b' : '#ef4444'"
              />
            </div>
          </div>

          <!-- 操作日志 -->
          <div class="log-section">
            <h4 class="log-title">通模操作日志</h4>
            <div class="log-list">
              <div v-for="log in operationLogs" :key="log.id" class="log-entry">
                <div class="log-dot" />
                <div class="log-body">
                  <span class="log-text">{{ log.text }}</span>
                  <span class="log-time">{{ log.time }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 底部：审核操作日志 -->
    <div class="panel" style="margin-top: 20px">
      <div class="panel-head">
        <h3 class="section-title">审核操作日志</h3>
        <p class="section-sub">记录所有与证据相关的审核及变更操作</p>
      </div>
      <el-table :data="auditLogs" border size="small" empty-text="暂无审核记录" style="width: 100%">
        <el-table-column prop="time" label="操作时间" width="180" />
        <el-table-column prop="operator" label="操作人" width="120" />
        <el-table-column prop="action" label="操作类型" width="140">
          <template #default="{ row }">
            <el-tag size="small" :type="actionTagType(row.action)">{{ row.action }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="target" label="操作对象" />
        <el-table-column prop="remark" label="备注" show-overflow-tooltip />
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getEvent } from '../api/events'

const route = useRoute()
const eventId = computed(() => route.params.id)

const loading = ref(false)
const activeTab = ref('evidence')
const eventData = ref({})
const evidenceList = ref([])
const currentVersion = ref('V1.3')
const completeness = ref(92)
const auditStatus = ref('已归档')

const auditStatusType = computed(() => {
  const m = { '已归档': 'success', '已审核': 'success', '审核中': 'warning', '待审核': 'info' }
  return m[auditStatus.value] || 'info'
})

const latestOperation = computed(() => {
  if (auditLogs.value.length) return auditLogs.value[0].action
  return '—'
})

const form = reactive({
  evidenceType: '运维复盘记录',
  docNo: '',
  docTitle: '',
  department: '',
  docDate: '',
  relatedEventNo: '',
  auditStatus: '待审核',
  content: ''
})

function resetForm() {
  form.evidenceType = '运维复盘记录'
  form.docNo = ''
  form.docTitle = ''
  form.department = ''
  form.docDate = ''
  form.relatedEventNo = ''
  form.auditStatus = '待审核'
  form.content = ''
}

const progressItems = ref([
  { label: '来源部门审核模块', pct: 100 },
  { label: '分类依据检查', pct: 100 },
  { label: '审核依据验证', pct: 100 },
  { label: '结构化导入验证', pct: 100 }
])

const operationLogs = ref([
  { id: 1, text: '证据 DOC-0312 已完成结构化导入', time: '2024-12-15 14:32' },
  { id: 2, text: '审核员张工完成证据核验', time: '2024-12-15 11:20' },
  { id: 3, text: '来源部门确认文档真实性', time: '2024-12-14 17:45' },
  { id: 4, text: '新增证据 DOC-0312 (运维复盘记录)', time: '2024-12-14 09:10' },
  { id: 5, text: '版本更新至 V1.3', time: '2024-12-13 16:55' }
])

const auditLogs = ref([
  { time: '2024-12-15 14:32', operator: '李工', action: '导入确认', target: 'DOC-0312', remark: '结构化导入完成，数据完整' },
  { time: '2024-12-15 11:20', operator: '张工', action: '审核通过', target: 'DOC-0312', remark: '内容与事件匹配，审核通过' },
  { time: '2024-12-14 17:45', operator: '王主任', action: '部门确认', target: 'DOC-0312', remark: '确认文档来源真实性' },
  { time: '2024-12-14 09:10', operator: '赵工', action: '新增证据', target: 'DOC-0312', remark: '录入运维复盘记录' },
  { time: '2024-12-13 16:55', operator: '系统', action: '版本变更', target: '证据链版本', remark: '版本从 V1.2 更新至 V1.3' }
])

function actionTagType(action) {
  const m = { '审核通过': 'success', '导入确认': 'success', '部门确认': '', '新增证据': 'warning', '版本变更': 'info' }
  return m[action] || 'info'
}

async function fetchEventData() {
  loading.value = true
  try {
    const res = await getEvent(eventId.value)
    const d = res.data || {}
    eventData.value = d
    evidenceList.value = d.evidence || []
    if (d.event_no) form.relatedEventNo = d.event_no
    if (d.evidence?.length) {
      const latest = d.evidence[d.evidence.length - 1]
      currentVersion.value = latest.version_info || 'V1.3'
    }
  } catch {
    eventData.value = { event_no: `HFE-${eventId.value || '0000'}` }
    evidenceList.value = []
  } finally {
    loading.value = false
  }
}

onMounted(fetchEventData)
</script>

<style scoped>
.evidence-page {
  background: #f5f7fa;
  min-height: calc(100vh - 120px);
  padding: 0 0 24px;
}

.tab-bar {
  background: #fff;
  padding: 0 24px;
  border-radius: 8px;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.tab-bar :deep(.el-tabs__header) {
  margin: 0;
}

.tab-bar :deep(.el-tabs__nav-wrap::after) {
  height: 1px;
}

.title-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 0 4px;
}

.page-title {
  font-size: 22px;
  font-weight: 700;
  color: #1a365d;
  margin: 0;
}

.title-actions {
  display: flex;
  gap: 8px;
}

/* 信息卡片 */
.info-cards {
  margin-bottom: 16px;
}

.info-card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  min-height: 90px;
  justify-content: center;
}

.info-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.info-value {
  font-size: 28px;
  font-weight: 700;
  color: #1a365d;
  line-height: 1.3;
}

.info-value.code {
  font-size: 18px;
  font-family: 'Courier New', monospace;
  letter-spacing: 1px;
}

.info-value.highlight {
  color: #10b981;
}

.info-value.small {
  font-size: 14px;
  font-weight: 500;
  color: #4a5568;
}

.info-tag {
  margin-top: 4px;
}

/* 面板 */
.panel {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.panel-head {
  margin-bottom: 20px;
}

.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #1a365d;
  margin: 0 0 4px;
}

.section-sub {
  font-size: 13px;
  color: #909399;
  margin: 0;
}

/* 表单 */
.evidence-form :deep(.el-form-item__label) {
  font-weight: 600;
  color: #4a5568;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 8px;
}

/* 完整度进度 */
.progress-list {
  margin-bottom: 28px;
}

.progress-item {
  margin-bottom: 18px;
}

.progress-item:last-child {
  margin-bottom: 0;
}

.progress-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.progress-label {
  font-size: 14px;
  color: #4a5568;
  font-weight: 500;
}

.progress-pct {
  font-size: 14px;
  font-weight: 700;
  color: #10b981;
}

/* 操作日志 */
.log-section {
  border-top: 1px solid #ebeef5;
  padding-top: 20px;
}

.log-title {
  font-size: 15px;
  font-weight: 600;
  color: #1a365d;
  margin: 0 0 16px;
}

.log-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.log-entry {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.log-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #2563eb;
  margin-top: 6px;
  flex-shrink: 0;
}

.log-body {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.log-text {
  font-size: 13px;
  color: #4a5568;
}

.log-time {
  font-size: 12px;
  color: #a0aec0;
}
</style>
