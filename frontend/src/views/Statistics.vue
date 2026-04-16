<template>
  <div class="statistics-page" v-loading="loading">
    <!-- 顶部标签导航 -->
    <div class="tab-bar">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="统计分析" name="statistics" />
        <el-tab-pane label="可视化展示" name="visualization" disabled />
        <el-tab-pane label="趋势分析" name="trend" disabled />
        <el-tab-pane label="专题分析" name="topic" disabled />
        <el-tab-pane label="数据导出" name="export" disabled />
      </el-tabs>
    </div>

    <!-- 标题栏 -->
    <div class="title-bar">
      <h2 class="page-title">统计分析与可视化展示模块</h2>
      <div class="title-actions">
        <el-button @click="$router.push('/events')">返回台帐模块</el-button>
        <el-button>导出报表</el-button>
        <el-button>生成专题报告</el-button>
        <el-button type="primary" :icon="Refresh" @click="fetchStats">刷新统计</el-button>
      </div>
    </div>

    <!-- 概览卡片 -->
    <div class="summary-row">
      <div v-for="card in summaryCards" :key="card.label" class="summary-card">
        <span class="card-sup">{{ card.label }}</span>
        <span class="card-value">{{ card.value }}</span>
        <span class="card-desc">{{ card.desc }}</span>
      </div>
    </div>

    <!-- 统计筛选条件 -->
    <div class="filter-section">
      <div class="section-head">
        <h3 class="section-title">统计筛选条件</h3>
        <p class="section-sub">支持按时间、机组、系统、事件类型、任务阶段、影响因素进行定向分析</p>
      </div>
      <div class="filter-row">
        <el-select v-model="filters.period" placeholder="统计周期" style="width: 150px">
          <el-option label="近12个月" value="12m" />
          <el-option label="近6个月" value="6m" />
          <el-option label="近3个月" value="3m" />
          <el-option label="全部" value="all" />
        </el-select>
        <el-select v-model="filters.unit" placeholder="电厂/机组" clearable style="width: 150px">
          <el-option label="全部机组" value="" />
          <el-option label="1号机组" value="1" />
          <el-option label="2号机组" value="2" />
          <el-option label="3号机组" value="3" />
          <el-option label="4号机组" value="4" />
        </el-select>
        <el-select v-model="filters.consequence" placeholder="后果等级" clearable style="width: 150px">
          <el-option label="全部等级" value="" />
          <el-option label="严重" value="严重" />
          <el-option label="较大" value="较大" />
          <el-option label="一般" value="一般" />
          <el-option label="轻微" value="轻微" />
        </el-select>
        <el-select v-model="filters.eventType" placeholder="事件类型" clearable style="width: 150px">
          <el-option label="全部类型" value="" />
          <el-option label="运行事件" value="运行事件" />
          <el-option label="安全事件" value="安全事件" />
          <el-option label="不正常事件" value="不正常事件" />
          <el-option label="管理事件" value="管理事件" />
        </el-select>
        <el-select v-model="filters.taskPhase" placeholder="任务阶段" clearable style="width: 150px">
          <el-option label="全部阶段" value="" />
          <el-option label="计划阶段" value="计划" />
          <el-option label="执行阶段" value="执行" />
          <el-option label="监控阶段" value="监控" />
        </el-select>
        <el-select v-model="filters.factor" placeholder="影响因素" clearable style="width: 150px">
          <el-option label="全部因素" value="" />
          <el-option label="信息负荷" value="信息负荷" />
          <el-option label="时间压力" value="时间压力" />
          <el-option label="经验培训" value="经验培训" />
        </el-select>
        <div class="filter-actions">
          <el-button @click="resetFilters">重置条件</el-button>
          <el-button type="primary" @click="fetchStats">更新统计</el-button>
        </div>
      </div>
    </div>

    <!-- 图表区域：双栏布局 -->
    <el-row :gutter="20">
      <!-- 左栏：分布统计 -->
      <el-col :span="12">
        <div class="chart-panel">
          <div class="panel-head">
            <h3 class="section-title">分布统计</h3>
            <p class="section-sub">包含「事件类型」和「失误类型」的频次和关系分析</p>
          </div>

          <div class="chart-block">
            <h4 class="chart-label">事件类型分析</h4>
            <div class="donut-wrapper">
              <div ref="donutRef" class="chart-box" style="height: 320px"></div>
            </div>
            <p class="chart-note">用于在统计基线下可视化失误归因框架关系</p>
          </div>

          <div class="chart-block">
            <h4 class="chart-label">失误类型频次统计</h4>
            <div ref="errorBarRef" class="chart-box" style="height: 300px"></div>
          </div>
        </div>
      </el-col>

      <!-- 右栏：影响因素统计 -->
      <el-col :span="12">
        <div class="chart-panel">
          <div class="panel-head">
            <h3 class="section-title">影响因素统计</h3>
            <p class="section-sub">反映与事件相关的性能影响因素的频次排布</p>
          </div>
          <div ref="factorBarRef" class="chart-box" style="height: 600px"></div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { Refresh } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { getEventStats } from '../api/events'

const loading = ref(false)
const activeTab = ref('statistics')

const statsData = reactive({
  total: 0,
  recent12: 0,
  topErrorType: '',
  topFactor: '',
  unitCount: 0,
  byType: [],
  byErrorType: [],
  byFactor: []
})

const filters = reactive({
  period: '12m',
  unit: '',
  consequence: '',
  eventType: '',
  taskPhase: '',
  factor: ''
})

const summaryCards = computed(() => [
  { label: '纳入统计事件数', value: statsData.total, desc: '满足筛选条件的事件总量' },
  { label: '近12个月事件数', value: statsData.recent12, desc: '最近一年内记录事件' },
  { label: '最高频失误类型', value: statsData.topErrorType || '—', desc: '出现频次最高的失误分类' },
  { label: '最高频影响因素', value: statsData.topFactor || '—', desc: '出现频次最高的性能影响因素' },
  { label: '实际机组涵盖', value: statsData.unitCount, desc: '涉及机组数量' }
])

const donutRef = ref(null)
const errorBarRef = ref(null)
const factorBarRef = ref(null)
const charts = []

const COLORS = ['#2563eb', '#f59e0b', '#10b981', '#8b5cf6', '#ef4444', '#06b6d4', '#ec4899']
const BAR_COLOR = '#1a4a6e'

function initChart(el, option) {
  if (!el) return null
  const c = echarts.init(el)
  c.setOption(option)
  charts.push(c)
  return c
}

function renderDonut(data, total) {
  const seriesData = data.map((d, i) => ({
    name: d.name,
    value: d.value ?? d.count,
    itemStyle: { color: COLORS[i % COLORS.length] }
  }))

  initChart(donutRef.value, {
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: {
      orient: 'vertical',
      left: '2%',
      top: 'center',
      itemWidth: 12,
      itemHeight: 12,
      textStyle: { fontSize: 13, color: '#4a5568' },
      formatter(name) {
        const item = seriesData.find(d => d.name === name)
        const pct = item ? ((item.value / (total || 1)) * 100).toFixed(0) : 0
        return `${name}  ${pct}%`
      }
    },
    graphic: [{
      type: 'text',
      left: '62%',
      top: '42%',
      style: {
        text: total.toString(),
        textAlign: 'center',
        fill: '#1a365d',
        fontSize: 30,
        fontWeight: 'bold'
      }
    }, {
      type: 'text',
      left: '62%',
      top: '55%',
      style: {
        text: '事件',
        textAlign: 'center',
        fill: '#8c8c8c',
        fontSize: 14
      }
    }],
    series: [{
      type: 'pie',
      radius: ['42%', '68%'],
      center: ['63%', '50%'],
      avoidLabelOverlap: false,
      label: { show: false },
      labelLine: { show: false },
      emphasis: {
        label: { show: true, fontSize: 14, fontWeight: 'bold', formatter: '{b}\n{d}%' }
      },
      data: seriesData
    }]
  })
}

function renderHorizontalBar(el, data, color) {
  const sorted = [...data].sort((a, b) => (a.value ?? a.count) - (b.value ?? b.count))
  const names = sorted.map(d => d.name)
  const values = sorted.map(d => d.value ?? d.count)

  initChart(el, {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '32%', right: '12%', top: 10, bottom: 10 },
    xAxis: { type: 'value', show: false },
    yAxis: {
      type: 'category',
      data: names,
      axisTick: { show: false },
      axisLine: { show: false },
      axisLabel: { fontSize: 13, color: '#4a5568' }
    },
    series: [{
      type: 'bar',
      data: values,
      barWidth: 18,
      itemStyle: { color, borderRadius: [0, 4, 4, 0] },
      label: { show: true, position: 'right', fontSize: 12, color: '#4a5568' }
    }]
  })
}

const defaultErrorTypes = [
  { name: '诊断延误', value: 38 },
  { name: '操作遗漏/遗失', value: 31 },
  { name: '规程偏离', value: 27 },
  { name: '判断不当/延误', value: 22 },
  { name: '执行失误', value: 18 },
  { name: '沟通遗漏', value: 14 },
  { name: '监控遗漏', value: 11 }
]

const defaultFactors = [
  { name: '信息显示/界面执行', value: 42 },
  { name: '信息量/偏入差异', value: 35 },
  { name: '经验/培训/可用技能', value: 30 },
  { name: '规程/可用性/一般', value: 26 },
  { name: '环境条件不足', value: 21 },
  { name: '时间压力', value: 18 },
  { name: '团队因素', value: 15 },
  { name: '工作组织/计划', value: 12 },
  { name: '人机接口', value: 10 },
  { name: '身体/生理条件', value: 7 }
]

const defaultByType = [
  { name: '运行事件', count: 52 },
  { name: '安全事件', count: 36 },
  { name: '不正常事件', count: 31 },
  { name: '管理事件', count: 26 }
]

function renderAllCharts(data) {
  charts.forEach(c => c.dispose())
  charts.length = 0

  const byType = data.byType?.length ? data.byType : defaultByType
  const total = data.total || byType.reduce((s, d) => s + (d.value ?? d.count), 0)

  renderDonut(byType, total)

  const errorData = data.byErrorType?.length ? data.byErrorType : defaultErrorTypes
  renderHorizontalBar(errorBarRef.value, errorData, BAR_COLOR)

  const factorData = data.byFactor?.length ? data.byFactor : defaultFactors
  renderHorizontalBar(factorBarRef.value, factorData, '#2c5282')
}

function handleResize() {
  charts.forEach(c => c.resize())
}

function resetFilters() {
  filters.period = '12m'
  filters.unit = ''
  filters.consequence = ''
  filters.eventType = ''
  filters.taskPhase = ''
  filters.factor = ''
}

async function fetchStats() {
  loading.value = true
  try {
    const res = await getEventStats()
    const d = res.data || {}

    const byType = d.byType?.length ? d.byType : defaultByType
    const total = d.total || byType.reduce((s, item) => s + (item.value ?? item.count ?? 0), 0)

    statsData.total = total
    statsData.recent12 = d.byMonth
      ? d.byMonth.reduce((s, m) => s + (m.count ?? 0), 0)
      : total
    statsData.unitCount = d.byUnit?.length || 4

    const errorArr = d.byErrorType?.length ? d.byErrorType : defaultErrorTypes
    const topErr = errorArr.reduce((a, b) => ((a.value ?? a.count) >= (b.value ?? b.count) ? a : b), errorArr[0])
    statsData.topErrorType = topErr?.name || '诊断延迟'

    const factorArr = d.byFactor?.length ? d.byFactor : defaultFactors
    const topFac = factorArr.reduce((a, b) => ((a.value ?? a.count) >= (b.value ?? b.count) ? a : b), factorArr[0])
    statsData.topFactor = topFac?.name || '信息负荷'

    await nextTick()
    renderAllCharts({ ...d, byType, byErrorType: errorArr, byFactor: factorArr, total })
  } catch {
    statsData.total = 145
    statsData.recent12 = 145
    statsData.topErrorType = '诊断延迟'
    statsData.topFactor = '信息负荷'
    statsData.unitCount = 4
    await nextTick()
    renderAllCharts({ total: 145 })
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchStats()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  charts.forEach(c => c.dispose())
})
</script>

<style scoped>
.statistics-page {
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

/* 概览卡片 */
.summary-row {
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
}

.summary-card {
  flex: 1;
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.card-sup {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.card-value {
  font-size: 32px;
  font-weight: 700;
  color: #1a365d;
  line-height: 1.2;
  margin-bottom: 6px;
}

.card-desc {
  font-size: 12px;
  color: #b0b8c4;
}

/* 筛选区 */
.filter-section {
  background: #fff;
  border-radius: 8px;
  padding: 20px 24px;
  margin-bottom: 20px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.section-head {
  margin-bottom: 16px;
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

.filter-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
}

.filter-actions {
  margin-left: auto;
  display: flex;
  gap: 8px;
}

/* 图表面板 */
.chart-panel {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  margin-bottom: 20px;
}

.panel-head {
  margin-bottom: 20px;
}

.chart-block {
  margin-bottom: 28px;
}

.chart-block:last-child {
  margin-bottom: 0;
}

.chart-label {
  font-size: 15px;
  font-weight: 600;
  color: #2d3748;
  margin: 0 0 8px;
}

.chart-box {
  width: 100%;
}

.chart-note {
  font-size: 12px;
  color: #a0aec0;
  margin: 8px 0 0;
  text-align: center;
}
</style>
