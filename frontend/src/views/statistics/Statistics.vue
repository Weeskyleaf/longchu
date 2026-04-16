<template>
  <div class="statistics-page" v-loading="loading">
    <!-- 汇总卡片 -->
    <el-row :gutter="16" class="summary-row">
      <el-col :span="6" v-for="item in summaryCards" :key="item.title">
        <el-card shadow="hover" class="summary-card" :body-style="{ padding: '20px' }">
          <div class="summary-content">
            <div class="summary-info">
              <div class="summary-value">{{ item.value }}</div>
              <div class="summary-label">{{ item.title }}</div>
            </div>
            <el-icon :size="48" :color="item.color" class="summary-icon">
              <component :is="item.icon" />
            </el-icon>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="16">
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header><span class="chart-title">事件类型分布</span></template>
          <div ref="chartTypeRef" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header><span class="chart-title">各机组事件数量</span></template>
          <div ref="chartUnitRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>
    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header><span class="chart-title">事件趋势</span></template>
          <div ref="chartTrendRef" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header><span class="chart-title">后果等级分布</span></template>
          <div ref="chartLevelRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, markRaw } from 'vue'
import * as echarts from 'echarts'
import { getEventStats } from '@/api/events'
import { Tickets, Calendar, Warning, TrendCharts } from '@element-plus/icons-vue'

const loading = ref(false)
const chartTypeRef = ref(null)
const chartUnitRef = ref(null)
const chartTrendRef = ref(null)
const chartLevelRef = ref(null)

let charts = []

const summaryCards = ref([
  { title: '事件总数', value: 0, color: '#409EFF', icon: markRaw(Tickets) },
  { title: '本月新增', value: 0, color: '#67C23A', icon: markRaw(Calendar) },
  { title: '严重事件', value: 0, color: '#F56C6C', icon: markRaw(Warning) },
  { title: '涉及机组数', value: 0, color: '#E6A23C', icon: markRaw(TrendCharts) },
])

function initChart(el, option) {
  const chart = echarts.init(el)
  chart.setOption(option)
  charts.push(chart)
  return chart
}

function renderCharts(stats) {
  const typeData = stats.byType || []
  initChart(chartTypeRef.value, {
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0 },
    color: ['#409EFF', '#67C23A', '#E6A23C', '#F56C6C'],
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '45%'],
      label: { formatter: '{b}\n{d}%' },
      data: typeData,
    }],
  })

  const unitData = stats.byUnit || []
  initChart(chartUnitRef.value, {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: unitData.map(d => d.name), axisLabel: { rotate: 0 } },
    yAxis: { type: 'value', name: '事件数' },
    series: [{
      type: 'bar',
      data: unitData.map(d => d.value),
      itemStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
        { offset: 0, color: '#409EFF' },
        { offset: 1, color: '#79bbff' },
      ])},
      barWidth: '40%',
    }],
    grid: { left: 50, right: 20, top: 30, bottom: 30 },
  })

  const trendRaw = stats.byMonth || []
  const trendData = trendRaw.map(d => ({ month: d.name, count: d.value }))
  initChart(chartTrendRef.value, {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: trendData.map(d => d.month), boundaryGap: false },
    yAxis: { type: 'value', name: '事件数' },
    series: [{
      type: 'line',
      data: trendData.map(d => d.count),
      smooth: true,
      areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
        { offset: 0, color: 'rgba(64,158,255,0.3)' },
        { offset: 1, color: 'rgba(64,158,255,0.02)' },
      ])},
      lineStyle: { width: 2, color: '#409EFF' },
      itemStyle: { color: '#409EFF' },
    }],
    grid: { left: 50, right: 20, top: 30, bottom: 30 },
  })

  const levelData = stats.byConsequence || []
  initChart(chartLevelRef.value, {
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0 },
    color: ['#F56C6C', '#E6A23C', '#909399', '#67C23A'],
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '45%'],
      roseType: 'radius',
      label: { formatter: '{b}\n{d}%' },
      data: levelData,
    }],
  })
}

async function fetchStats() {
  loading.value = true
  try {
    const res = await getEventStats()
    const stats = res.data || res || {}
    summaryCards.value[0].value = stats.total ?? 0
    summaryCards.value[1].value = stats.byMonth?.length ?? 0
    summaryCards.value[2].value = stats.byConsequence?.find(c => c.name === '安全相关')?.value ?? 0
    summaryCards.value[3].value = stats.byUnit?.length ?? 0
    renderCharts(stats)
  } catch {
    renderCharts({})
  } finally {
    loading.value = false
  }
}

function handleResize() {
  charts.forEach(c => c.resize())
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
.statistics-page { display: flex; flex-direction: column; gap: 16px; }
.summary-row { margin-bottom: 0; }
.summary-card { border-radius: 8px; }
.summary-content { display: flex; justify-content: space-between; align-items: center; }
.summary-value { font-size: 32px; font-weight: 700; color: #303133; }
.summary-label { font-size: 14px; color: #909399; margin-top: 4px; }
.summary-icon { opacity: 0.85; }
.chart-card { border-radius: 8px; }
.chart-title { font-weight: 600; font-size: 15px; color: #303133; }
.chart-box { height: 340px; }
</style>
