<template>
  <div class="event-detail-page" v-loading="loading">
    <div class="detail-top">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/events' }">事件台账</el-breadcrumb-item>
        <el-breadcrumb-item>事件信息模块</el-breadcrumb-item>
        <el-breadcrumb-item>{{ event.event_code || event.event_no || '--' }}</el-breadcrumb-item>
      </el-breadcrumb>

      <div class="detail-title-row">
        <h1 class="detail-title">{{ event.event_title || '加载中...' }}</h1>
        <div class="detail-title-actions">
          <el-button @click="$router.push('/events')"><el-icon><Back /></el-icon>返回事件模块</el-button>
          <el-button type="primary" @click="$router.push(`/analysis/preview`)"><el-icon><DataLine /></el-icon>HRA分析</el-button>
          <el-button type="warning" @click="$router.push(`/events/${route.params.id}/evidence`)"><el-icon><Connection /></el-icon>证据链溯源</el-button>
          <el-button><el-icon><Download /></el-icon>导出事件摘要</el-button>
        </div>
      </div>

      <div class="nav-tabs">
        <span v-for="(tab, idx) in navTabs" :key="idx" class="nav-tab" :class="{ active: activeTab === idx }" @click="activeTab = idx">{{ tab }}</span>
      </div>
    </div>

    <div class="info-cards-row">
      <div class="info-card">
        <span class="info-card__label">事件编号</span>
        <span class="info-card__value">{{ event.event_code || event.event_no || 'HF-2024-027' }}</span>
        <span class="info-card__desc">事件唯一标识编码</span>
      </div>
      <div class="info-card">
        <span class="info-card__label">发生时间</span>
        <span class="info-card__value">{{ event.occur_time ? event.occur_time.replace('T', ' ').substring(0, 16) : '2024-09-18 10:42' }}</span>
        <span class="info-card__desc">事故发生的具体时间</span>
      </div>
      <div class="info-card">
        <span class="info-card__label">运行工况</span>
        <span class="info-card__value">{{ event.operation_mode || '功率运行' }}</span>
        <span class="info-card__desc">事故时机组运行状态</span>
      </div>
      <div class="info-card">
        <span class="info-card__label">后果等级</span>
        <span class="info-card__value consequence">
          <span class="consequence-dot" :style="{ background: consequenceDotColor(event.consequence_level) }"></span>
          {{ event.consequence_level || '一般后果' }}
        </span>
        <span class="info-card__desc">已完成后果影响评估，属低风险等级</span>
      </div>
      <div class="info-card">
        <span class="info-card__label">完整度</span>
        <span class="info-card__value completeness-val">{{ event.completeness ?? 100 }}%</span>
        <span class="info-card__desc">已完成全部结构化信息录入</span>
      </div>
    </div>

    <el-row :gutter="16" class="section-row">
      <el-col :span="12">
        <div class="section-card">
          <div class="section-heading">基本信息</div>
          <el-descriptions :column="1" border class="info-desc">
            <el-descriptions-item label="事件编号">{{ event.event_code || event.event_no }}</el-descriptions-item>
            <el-descriptions-item label="事件名称">{{ event.event_title }}</el-descriptions-item>
            <el-descriptions-item label="事件类别">
              <el-tag :type="typeTagMap[event.event_type] || 'info'" size="small">{{ event.event_type }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="事件判断">{{ event.main_category || '--' }}</el-descriptions-item>
            <el-descriptions-item label="电厂/机组">{{ event.plant_name || '某厂' }} {{ event.unit_no ? `${event.unit_no}号机组` : '--' }}</el-descriptions-item>
            <el-descriptions-item label="系统设备">{{ event.system_code || '--' }}</el-descriptions-item>
            <el-descriptions-item label="来源类型">{{ event.source_type || '--' }}</el-descriptions-item>
            <el-descriptions-item label="事件结果">{{ event.consequence_level || '--' }}</el-descriptions-item>
            <el-descriptions-item label="原始版本号">{{ event.version || 'v1.0' }}</el-descriptions-item>
          </el-descriptions>
        </div>
      </el-col>
      <el-col :span="12">
        <div class="section-card">
          <div class="section-heading">结构化标签与影响因素</div>

          <div class="sub-heading">标签分类</div>
          <div class="tag-group">
            <el-tag v-for="tag in displayTags" :key="tag.name" :type="tag.type" effect="light" class="struct-tag">{{ tag.name }}</el-tag>
            <span v-if="!displayTags.length" class="empty-hint">暂无标签</span>
          </div>

          <div class="sub-heading" style="margin-top: 20px">影响因素</div>
          <div class="factor-list">
            <div v-for="factor in displayFactors" :key="factor.name" class="factor-row">
              <span class="factor-name">{{ factor.name }}</span>
              <el-tag :type="factorLevelTagType(factor.level)" size="small" class="factor-level-tag">{{ factor.level }}</el-tag>
              <div class="factor-bar-track">
                <div class="factor-bar-fill" :style="{ width: factorBarWidth(factor.level) + '%', background: factorBarColor(factor.level) }"></div>
              </div>
            </div>
            <span v-if="!displayFactors.length" class="empty-hint">暂无因素数据</span>
          </div>
        </div>
      </el-col>
    </el-row>

    <div class="section-card section-row">
      <div class="section-heading">事件摘要</div>
      <div class="summary-block">{{ event.event_summary || event.raw_text || '暂无摘要信息' }}</div>
    </div>

    <el-row :gutter="16" class="section-row">
      <el-col :span="12">
        <div class="section-card">
          <div class="section-heading">事件进展序列</div>
          <div class="section-sub-desc">基于事件时间线还原关键操作节点</div>
          <el-timeline class="event-timeline">
            <el-timeline-item v-for="(item, idx) in eventSequence" :key="idx" :color="idx === 0 ? '#f56c6c' : '#409eff'">
              <div class="timeline-node-title">{{ item.time }} · {{ item.title }}</div>
              <div class="timeline-node-desc">{{ item.desc }}</div>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-if="!eventSequence.length" description="暂无进展序列" :image-size="60" />
        </div>
      </el-col>
      <el-col :span="12">
        <div class="section-card">
          <div class="section-heading">处理状态与版本跟踪</div>
          <el-timeline class="status-timeline">
            <el-timeline-item v-for="(item, idx) in statusTimeline" :key="idx" :type="idx === statusTimeline.length - 1 ? 'success' : 'primary'">
              <div class="timeline-node-title">{{ item.date }} · {{ item.action }}</div>
              <div class="timeline-node-desc">{{ item.desc }}</div>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-if="!statusTimeline.length" description="暂无状态记录" :image-size="60" />

          <div class="sub-heading" style="margin-top: 20px">证据链摘要</div>
          <div class="evidence-list">
            <div v-for="ev in evidenceItems" :key="ev" class="evidence-item">
              <el-icon class="evidence-icon"><Document /></el-icon>
              <span>{{ ev }}</span>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>
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
  '设备故障': 'danger', '人因失误': 'warning', '程序缺陷': '',
  '组织因素': 'info', '外部事件': 'success', '运行事件': ''
}

const defaultTags = [
  { name: '信息显示', type: 'danger' },
  { name: '诊断延迟', type: 'warning' },
  { name: '时间压力', type: '' },
  { name: '操作遗漏', type: 'info' },
  { name: '规程偏离', type: 'success' }
]

const defaultFactors = [
  { name: '可用时间', level: '高' },
  { name: '压力/应激', level: '高' },
  { name: '复杂程度', level: '一般' },
  { name: '经验/培训', level: '中' },
  { name: '规程质量', level: '一般' },
  { name: '人机界面', level: '低' },
  { name: '团队因素', level: '一般' }
]

const displayTags = computed(() => {
  const tags = event.value.tags
  if (tags?.length) return tags.map(t => ({ name: t.tag_name, type: t.tag_type ? (({ '失误类型': 'danger', '行为分类': 'warning', '认知分类': '', '环境因素': 'info' })[t.tag_type] || '') : '' }))
  return defaultTags
})

const displayFactors = computed(() => {
  const factors = event.value.factors
  if (factors?.length) return factors.map(f => ({ name: f.factor_name, level: f.factor_level }))
  return defaultFactors
})

function consequenceDotColor(level) {
  const m = { '严重': '#f56c6c', '较大': '#e6a23c', '一般': '#409eff', '一般后果': '#409eff', '轻微': '#67c23a' }
  return m[level] || '#409eff'
}

function factorLevelTagType(level) {
  const m = { '高': 'danger', '较高': 'warning', '中': '', '一般': 'info', '低': 'success' }
  return m[level] || 'info'
}

function factorBarWidth(level) {
  const m = { '高': 100, '较高': 75, '中': 60, '一般': 40, '低': 20 }
  return m[level] ?? 50
}

function factorBarColor(level) {
  const m = { '高': '#f56c6c', '较高': '#e6a23c', '中': '#409eff', '一般': '#909399', '低': '#c0c4cc' }
  return m[level] ?? '#409eff'
}

const defaultSequence = [
  { time: '10:42', title: '事件触发', desc: '主控室操纵员发现一回路压力异常下降，RCS压力指示持续降低，初步判断可能发生冷却剂泄漏。' },
  { time: '10:44', title: '事故诊断', desc: '值班长组织操纵员按EOP规程进行事故诊断，确认安全注入信号触发条件。' },
  { time: '10:47', title: '安注投入', desc: '操纵员确认安全注入系统自动投入，检查安注泵运行状态及注入流量。' },
  { time: '10:52', title: '隔离操作', desc: '执行安全壳隔离程序，关闭相关隔离阀门，确认安全壳完整性。' },
  { time: '11:05', title: '状态稳定', desc: '确认堆芯冷却充分，RCS压力趋于稳定，事件进入监控阶段。' }
]

const defaultStatusTimeline = [
  { date: '2024-09-18', action: '事件录入', desc: '值班员完成事件初始信息录入，生成事件编号。' },
  { date: '2024-09-19', action: '结构化提取', desc: '系统完成事件文本的结构化信息自动提取。' },
  { date: '2024-09-20', action: '标签标注', desc: '完成失误类型与影响因素标签标注。' },
  { date: '2024-09-22', action: '审核通过', desc: '安全工程师完成事件审核，确认数据完整准确。' }
]

const eventSequence = computed(() => {
  const raw = event.value.event_sequence
  if (!raw) return defaultSequence
  if (Array.isArray(raw)) return raw
  return raw.split('\n').filter(Boolean).map(line => {
    const match = line.match(/^(\d{1,2}:\d{2})\s*[·\-—]\s*(.+?)[\s·\-—]+(.*)/)
    if (match) return { time: match[1], title: match[2], desc: match[3] }
    const simple = line.match(/^(\d{1,2}:\d{2})\s*[·\-—]\s*(.+)/)
    if (simple) return { time: simple[1], title: simple[2], desc: '' }
    return { time: '', title: line, desc: '' }
  })
})

const statusTimeline = computed(() => {
  const raw = event.value.status_history
  if (!raw) return defaultStatusTimeline
  if (Array.isArray(raw)) return raw
  return defaultStatusTimeline
})

const evidenceItems = computed(() => {
  const ev = event.value.evidence
  if (ev?.length) return ev.map(e => e.source_type || e)
  return ['事件初报', '编组日志', '纠错验证方案', '审核意见']
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

.detail-top {
  background: #fff;
  border-radius: 8px;
  padding: 20px 24px 0;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
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
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  gap: 4px;
  text-align: center;
}
.info-card__label {
  font-size: 12px;
  color: #909399;
}
.info-card__value {
  font-size: 18px;
  font-weight: 700;
  color: #1a365d;
  line-height: 1.3;
}
.info-card__value.consequence {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}
.consequence-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
}
.info-card__value.completeness-val {
  color: #67c23a;
}
.info-card__desc {
  font-size: 12px;
  color: #b0b8c4;
}

.section-row {
  margin-bottom: 16px;
}
.section-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  padding: 20px 24px;
  height: 100%;
}
.section-heading {
  font-size: 15px;
  font-weight: 700;
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

.info-desc :deep(.el-descriptions__label) {
  width: 100px;
  font-weight: 500;
  color: #606266;
}

.tag-group {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.struct-tag {
  border-radius: 4px;
}

.factor-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.factor-row {
  display: flex;
  align-items: center;
  gap: 10px;
}
.factor-name {
  font-size: 13px;
  color: #303133;
  width: 40%;
  flex-shrink: 0;
}
.factor-level-tag {
  flex-shrink: 0;
  min-width: 40px;
  text-align: center;
}
.factor-bar-track {
  flex: 1;
  height: 10px;
  background: #f0f2f5;
  border-radius: 5px;
  overflow: hidden;
}
.factor-bar-fill {
  height: 100%;
  border-radius: 5px;
  transition: width 0.4s ease;
}

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

.event-timeline,
.status-timeline {
  padding-left: 2px;
}
.timeline-node-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}
.timeline-node-desc {
  font-size: 13px;
  color: #606266;
  line-height: 1.6;
}

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
</style>
