<template>
  <div v-loading="loading">
    <h2 style="margin-bottom: 16px">统计分析</h2>

    <!-- Summary Cards -->
    <div class="stat-cards">
      <el-card shadow="never" class="stat-card">
        <div class="stat-value">{{ stats.total || 0 }}</div>
        <div class="stat-label">事件总数</div>
      </el-card>
      <el-card shadow="never" class="stat-card">
        <div class="stat-value" style="color: #67C23A">{{ stats.monthNew || 0 }}</div>
        <div class="stat-label">本月新增</div>
      </el-card>
      <el-card shadow="never" class="stat-card">
        <div class="stat-value" style="color: #E6A23C">{{ stats.safetyRelated || 0 }}</div>
        <div class="stat-label">安全相关事件</div>
      </el-card>
      <el-card shadow="never" class="stat-card">
        <div class="stat-value" style="color: #F56C6C">{{ stats.unitCount || 0 }}</div>
        <div class="stat-label">涉及机组数</div>
      </el-card>
    </div>

    <!-- Charts 2x2 -->
    <div class="chart-grid">
      <el-card shadow="never">
        <template #header>事件类型分布</template>
        <div ref="chartTypeRef" class="chart-container"></div>
      </el-card>
      <el-card shadow="never">
        <template #header>各机组事件数量</template>
        <div ref="chartUnitRef" class="chart-container"></div>
      </el-card>
      <el-card shadow="never">
        <template #header>事件趋势</template>
        <div ref="chartTrendRef" class="chart-container"></div>
      </el-card>
      <el-card shadow="never">
        <template #header>后果等级分布</template>
        <div ref="chartConseqRef" class="chart-container"></div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'
import { getEventStats } from '../api/events'

const loading = ref(false)
const stats = reactive({ total: 0, monthNew: 0, safetyRelated: 0, unitCount: 0 })
const chartTypeRef = ref(null)
const chartUnitRef = ref(null)
const chartTrendRef = ref(null)
const chartConseqRef = ref(null)
const charts = []

function initChart(el, option) {
  const chart = echarts.init(el)
  chart.setOption(option)
  charts.push(chart)
  return chart
}

function renderCharts(data) {
  // Pie: 事件类型分布
  initChart(chartTypeRef.value, {
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0, type: 'scroll' },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '45%'],
      label: { formatter: '{b}\n{d}%' },
      data: (data.byType || []).map(d => ({ name: d.name, value: d.count }))
    }]
  })

  // Bar: 各机组事件数量
  const unitData = data.byUnit || []
  initChart(chartUnitRef.value, {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: unitData.map(d => d.name), axisLabel: { interval: 0 } },
    yAxis: { type: 'value', name: '事件数' },
    series: [{
      type: 'bar',
      data: unitData.map(d => d.count),
      itemStyle: { color: '#409EFF' },
      barMaxWidth: 40
    }]
  })

  // Line: 事件趋势
  const monthData = data.byMonth || []
  initChart(chartTrendRef.value, {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: monthData.map(d => d.month), boundaryGap: false },
    yAxis: { type: 'value', name: '事件数' },
    series: [{
      type: 'line',
      data: monthData.map(d => d.count),
      smooth: true,
      areaStyle: { color: 'rgba(64,158,255,0.15)' },
      itemStyle: { color: '#409EFF' }
    }]
  })

  // Rose pie: 后果等级分布
  initChart(chartConseqRef.value, {
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0, type: 'scroll' },
    series: [{
      type: 'pie',
      radius: ['20%', '65%'],
      center: ['50%', '45%'],
      roseType: 'area',
      label: { formatter: '{b}\n{d}%' },
      data: (data.byConsequence || []).map(d => ({ name: d.name, value: d.count }))
    }]
  })
}

function handleResize() {
  charts.forEach(c => c.resize())
}

async function fetchStats() {
  loading.value = true
  try {
    const res = await getEventStats()
    const d = res.data || {}
    stats.total = d.total || 0
    stats.monthNew = d.monthNew || 0
    stats.safetyRelated = d.safetyRelated || 0
    stats.unitCount = d.unitCount || 0
    renderCharts(d)
  } catch {
    renderCharts({})
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
