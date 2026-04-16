<template>
  <div class="event-detail-page" v-loading="loading">
    <!-- 顶部区域 -->
    <div class="detail-top">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/events' }">事件台账</el-breadcrumb-item>
        <el-breadcrumb-item>事件信息模块</el-breadcrumb-item>
        <el-breadcrumb-item>{{ event.event_no || '--' }}</el-breadcrumb-item>
      </el-breadcrumb>

      <div class="detail-title-row">
        <h1 class="detail-title">{{ event.event_title || '加载中...' }}</h1>
        <div class="detail-title-actions">
          <el-button @click="$router.push('/events')">
            <el-icon><Back /></el-icon>返回事件模块
          </el-button>
          <el-button type="primary">
            <el-icon><DataLine /></el-icon>HRA分析
          </el-button>
          <el-button type="warning">
            <el-icon><Connection /></el-icon>证据链溯源
          </el-button>
          <el-button>
            <el-icon><Download /></el-icon>导出事件摘要
          </el-button>
        </div>
      </div>

      <!-- 装饰性标签导航 -->
      <div class="nav-tabs">
        <span
          v-for="(tab, idx) in navTabs"
          :key="idx"
          class="nav-tab"
          :class="{ active: activeTab === idx }"
          @click="activeTab = idx"
        >{{ tab }}</span>
      </div>
    </div>

    <!-- 信息指标卡片行 -->
    <div class="info-cards-row">
      <div class="info-card">
        <span class="info-card__label">事件编号</span>
        <span class="info-card__value">{{ event.event_no || '--' }}</span>
      </div>
      <div class="info-card">
        <span class="info-card__label">发生时间</span>
        <span class="info-card__value">{{ event.occur_time || '--' }}</span>
      </div>
      <div class="info-card">
        <span class="info-card__label">运行工况</span>
        <span class="info-card__value">{{ event.operation_mode || '--' }}</span>
      </div>
      <div class="info-card">
        <span class="info-card__label">后果等级</span>
        <span class="info-card__value">
          <el-tag :type="consequenceColor(event.consequence_level)" size="small">
            {{ event.consequence_level || '--' }}
          </el-tag>
        </span>
      </div>
      <div class="info-card">
        <span class="info-card__label">完整度</span>
        <span class="info-card__value completeness">{{ event.completeness ?? '--' }}%</span>
      </div>
    </div>

    <!-- Section 1 & 2: 双栏 - 基本信息 + 标签与影响因素 -->
    <el-row :gutter="16" class="section-row">
      <el-col :span="12">
        <el-card shadow="never" class="section-card">
          <div class="section-heading">基本信息</div>
          <el-descriptions :column="1" border class="info-desc">
            <el-descriptions-item label="事件编号">{{ event.event_no }}</el-descriptions-item>
            <el-descriptions-item label="事件名称">{{ event.event_title }}</el-descriptions-item>
            <el-descriptions-item label="事件类别">
              <el-tag :type="typeTagMap[event.event_type] || 'info'" size="small">
                {{ event.event_type }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="事件判断">{{ event.main_category || '--' }}</el-descriptions-item>
            <el-descriptions-item label="电厂/机组">{{ event.unit_no ? `${event.unit_no}号机组` : '--' }}</el-descriptions-item>
            <el-descriptions-item label="系统设备">{{ event.system_code || '--' }}</el-descriptions-item>
            <el-descriptions-item label="来源类型">{{ event.source_type || '--' }}</el-descriptions-item>
            <el-descriptions-item label="事件结果">{{ event.consequence_level || '--' }}</el-descriptions-item>
            <el-descriptions-item label="原始版本号">{{ event.version || 'v1.0' }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never" class="section-card">
          <div class="section-heading">结构化标签与影响因素</div>

          <div class="sub-heading">标签分类</div>
          <div class="tag-group">
            <el-tag
              v-for="tag in (event.tags || [])"
              :key="tag.id || tag.tag_name"
              :type="tagColorMap[tag.tag_type] || ''"
              effect="light"
              class="struct-tag"
            >{{ tag.tag_name }}</el-tag>
            <span v-if="!event.tags?.length" class="empty-hint">暂无标签</span>
          </div>

          <div class="sub-heading" style="margin-top: 20px">影响因素</div>
          <div class="factor-list">
            <div v-for="factor in (event.factors || [])" :key="factor.factor_name" class="factor-item">
              <div class="factor-meta">
                <span class="factor-name">{{ factor.factor_name }}</span>
                <span class="factor-category">{{ factor.factor_category }}</span>
              </div>
              <div class="factor-bar-wrap">
                <div
                  class="factor-bar"
                  :style="{
                    width: factorBarWidth(factor.factor_level) + '%',
                    background: factorBarColor(factor.factor_level)
                  }"
                />
                <span class="factor-level">{{ factor.factor_level }}</span>
              </div>
            </div>
            <span v-if="!event.factors?.length" class="empty-hint">暂无因素数据</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Section 3: 事件摘要 -->
    <el-card shadow="never" class="section-card section-row">
      <div class="section-heading">事件摘要</div>
      <div class="summary-block">{{ event.event_summary || '暂无摘要信息' }}</div>
    </el-card>

    <!-- Section 4: 双栏 - 事件进展序列 + 处理状态 -->
    <el-row :gutter="16" class="section-row">
      <el-col :span="12">
        <el-card shadow="never" class="section-card">
          <div class="section-heading">事件进展序列</div>
          <div class="section-sub-desc">基于事件时间线还原关键操作节点</div>
          <el-timeline class="event-timeline">
            <el-timeline-item
              v-for="(item, idx) in eventSequence"
              :key="idx"
              :timestamp="item.time"
              placement="top"
              :color="idx === 0 ? '#f56c6c' : '#409eff'"
            >
              <span class="timeline-desc">{{ item.desc }}</span>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-if="!eventSequence.length" description="暂无进展序列" :image-size="60" />
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never" class="section-card">
          <div class="section-heading">处理状态与版本跟踪</div>
          <el-timeline class="status-timeline">
            <el-timeline-item
              v-for="(item, idx) in statusTimeline"
              :key="idx"
              :timestamp="item.date"
              placement="top"
              :type="idx === statusTimeline.length - 1 ? 'success' : 'primary'"
            >
              <span class="timeline-desc">{{ item.action }}</span>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-if="!statusTimeline.length" description="暂无状态记录" :image-size="60" />

          <div class="sub-heading" style="margin-top: 20px">证据链摘要</div>
          <div class="evidence-list">
            <div v-for="ev in (event.evidence || [])" :key="ev.source_type" class="evidence-item">
              <el-icon class="evidence-icon"><Document /></el-icon>
              <span>{{ ev.source_type }}</span>
              <el-tag size="small" :type="ev.audit_status === '已审核' ? 'success' : 'warning'" style="margin-left: auto">
                {{ ev.audit_status }}
              </el-tag>
            </div>
            <span v-if="!event.evidence?.length" class="empty-hint">暂无证据数据</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Section 5: 任务映射结果 -->
    <el-card shadow="never" class="section-card section-row">
      <div class="section-heading">任务映射结果</div>
      <el-table :data="event.tasks || []" border size="small" style="width: 100%" empty-text="暂无任务数据">
        <el-table-column prop="task_no" label="任务编号" width="130" />
        <el-table-column prop="task_name" label="任务名称" min-width="180" show-overflow-tooltip />
        <el-table-column prop="task_type" label="任务类型" width="110">
          <template #default="{ row }">
            <el-tag size="small" effect="light">{{ row.task_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="任务阶段" width="100">
          <template #default="{ row }">{{ row.task_phase || row.operator_role || '--' }}</template>
        </el-table-column>
        <el-table-column label="操作对象" width="120">
          <template #default="{ row }">{{ row.operation_target || row.error_type || '--' }}</template>
        </el-table-column>
        <el-table-column label="可用时间" width="110">
          <template #default="{ row }">{{ row.available_time || '--' }}</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { Back, Download, DataLine, Connection, Document } from '@element-plus/icons-vue'
import { getEvent } from '../api/events'

const route = useRoute()
const loading = ref(false)
const event = ref({})
const activeTab = ref(0)

const navTabs = ['基本信息/量', '登录人/情报', '事件过程/描述', '可视信息描述']

const typeTagMap = {
  '设备故障': 'danger',
  '人因失误': 'warning',
  '程序缺陷': '',
  '组织因素': 'info',
  '外部事件': 'success'
}

const tagColorMap = {
  '失误类型': 'danger',
  '行为分类': 'warning',
  '认知分类': '',
  '环境因素': 'info'
}

function consequenceColor(level) {
  const map = { '严重': 'danger', '较大': 'warning', '一般': 'info', '轻微': 'success' }
  return map[level] || 'info'
}

function factorBarWidth(level) {
  const map = { '高': 90, '较高': 75, '中': 55, '较低': 35, '低': 18 }
  return map[level] ?? 50
}

function factorBarColor(level) {
  const map = { '高': '#f56c6c', '较高': '#e6a23c', '中': '#409eff', '较低': '#67c23a', '低': '#c0c4cc' }
  return map[level] ?? '#409eff'
}

const eventSequence = computed(() => {
  const raw = event.value.event_sequence
  if (!raw) return []
  if (Array.isArray(raw)) return raw
  return raw.split('\n').filter(Boolean).map(line => {
    const match = line.match(/^(\d{1,2}:\d{2})\s*[·\-—]\s*(.+)/)
    if (match) return { time: match[1], desc: match[2] }
    return { time: '', desc: line }
  })
})

const statusTimeline = computed(() => {
  const raw = event.value.status_history
  if (!raw) return []
  if (Array.isArray(raw)) return raw
  return []
})

async function fetchDetail() {
  loading.value = true
  try {
    const res = await getEvent(route.params.id)
    event.value = res.data || {}
  } catch {
    event.value = {}
  } finally {
    loading.value = false
  }
}

onMounted(fetchDetail)
</script>

<style scoped>
.event-detail-page {
  background: #f5f7fa;
  min-height: 100%;
}

/* ---- 顶部区域 ---- */
.detail-top {
  background: #fff;
  border-radius: 8px;
  padding: 20px 24px 0;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.detail-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 14px;
}
.detail-title {
  font-size: 22px;
  font-weight: 700;
  color: #1a365d;
  margin: 0;
}
.detail-title-actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.nav-tabs {
  display: flex;
  gap: 0;
  margin-top: 18px;
  border-bottom: 2px solid #ebeef5;
}
.nav-tab {
  padding: 10px 22px;
  font-size: 14px;
  color: #606266;
  cursor: pointer;
  position: relative;
  transition: color 0.2s;
}
.nav-tab.active {
  color: #1a365d;
  font-weight: 600;
}
.nav-tab.active::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  right: 0;
  height: 2px;
  background: #1a365d;
}
.nav-tab:hover {
  color: #1a365d;
}

/* ---- 指标卡片行 ---- */
.info-cards-row {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 14px;
  margin-bottom: 16px;
}
.info-card {
  background: #fff;
  border-radius: 8px;
  padding: 16px 18px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.info-card__label {
  font-size: 12px;
  color: #909399;
}
.info-card__value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}
.info-card__value.completeness {
  color: #67c23a;
}

/* ---- 通用分区样式 ---- */
.section-row {
  margin-bottom: 16px;
}
.section-card {
  border-radius: 8px;
  height: 100%;
}
.section-card :deep(.el-card__body) {
  padding: 20px 24px;
}
.section-heading {
  font-size: 15px;
  font-weight: 600;
  color: #1a365d;
  padding-left: 12px;
  border-left: 3px solid #1a365d;
  margin-bottom: 16px;
}
.section-sub-desc {
  font-size: 12px;
  color: #909399;
  margin-bottom: 14px;
}
.sub-heading {
  font-size: 13px;
  font-weight: 600;
  color: #606266;
  margin-bottom: 10px;
}

/* ---- 基本信息描述列表 ---- */
.info-desc :deep(.el-descriptions__label) {
  width: 100px;
  font-weight: 500;
  color: #606266;
}

/* ---- 标签 ---- */
.tag-group {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.struct-tag {
  border-radius: 4px;
}

/* ---- 影响因素条形图 ---- */
.factor-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.factor-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.factor-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.factor-name {
  font-size: 13px;
  color: #303133;
}
.factor-category {
  font-size: 11px;
  color: #909399;
}
.factor-bar-wrap {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 14px;
}
.factor-bar {
  height: 8px;
  border-radius: 4px;
  transition: width 0.4s ease;
}
.factor-level {
  font-size: 11px;
  color: #909399;
  flex-shrink: 0;
}

/* ---- 事件摘要 ---- */
.summary-block {
  background: #f8f9fb;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 16px 20px;
  line-height: 1.9;
  color: #606266;
  font-size: 14px;
  white-space: pre-wrap;
}

/* ---- 时间线 ---- */
.event-timeline,
.status-timeline {
  padding-left: 2px;
}
.timeline-desc {
  font-size: 13px;
  color: #303133;
}

/* ---- 证据链摘要 ---- */
.evidence-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.evidence-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #f8f9fb;
  border-radius: 6px;
  font-size: 13px;
  color: #303133;
}
.evidence-icon {
  color: #909399;
}

.empty-hint {
  font-size: 13px;
  color: #c0c4cc;
}

/* ---- 表格样式 ---- */
:deep(.el-table) {
  border-radius: 6px;
}
</style>
