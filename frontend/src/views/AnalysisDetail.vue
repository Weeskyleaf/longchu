<template>
  <div v-loading="loading">
    <div class="page-header">
      <h2>案例详情</h2>
      <el-button @click="$router.back()">返回列表</el-button>
    </div>

    <!-- Three-column layout -->
    <div class="three-column-layout">
      <!-- LEFT: 事件信息版块 -->
      <div class="left-column">
        <el-card shadow="never">
          <template #header>事件信息版块</template>
          <el-descriptions :column="1" border size="small">
            <el-descriptions-item label="案例编号">{{ detail.case_no }}</el-descriptions-item>
            <el-descriptions-item label="案例名称">{{ detail.case_name }}</el-descriptions-item>
            <el-descriptions-item label="分析方法">
              <el-tag size="small">{{ detail.analysis_method }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="分析路径">{{ detail.analysis_path }}</el-descriptions-item>
            <el-descriptions-item label="分析人员">{{ detail.analyst }}</el-descriptions-item>
            <el-descriptions-item label="电厂名称">{{ detail.plant_name }}</el-descriptions-item>
            <el-descriptions-item label="始发事件">{{ detail.initiating_event }}</el-descriptions-item>
            <el-descriptions-item label="基本事件">{{ detail.basic_event }}</el-descriptions-item>
            <el-descriptions-item label="工况">{{ detail.operation_condition }}</el-descriptions-item>
            <el-descriptions-item label="审核状态">
              <el-tag :type="detail.review_status === '已审核' ? 'success' : 'warning'" size="small">
                {{ detail.review_status }}
              </el-tag>
            </el-descriptions-item>
          </el-descriptions>
          <div v-if="detail.context_description" style="margin-top: 12px">
            <div style="font-weight: 600; margin-bottom: 6px; color: #606266">场景描述</div>
            <div class="text-block-sm">{{ detail.context_description }}</div>
          </div>
        </el-card>
      </div>

      <!-- CENTER: 量化结果板块 -->
      <div class="center-column">
        <el-card shadow="never">
          <template #header>量化结果板块</template>

          <!-- Calculation Tasks -->
          <div v-for="(task, idx) in (detail.tasks || [])" :key="idx" style="margin-bottom: 20px">
            <h4 style="margin-bottom: 12px; color: #303133">
              {{ task.task_type === 'diagnosis' ? '诊断任务' : '动作任务' }} 计算过程
            </h4>

            <el-descriptions :column="2" border size="small" style="margin-bottom: 12px">
              <el-descriptions-item label="名义HEP">{{ formatNum(task.nominal_hep) }}</el-descriptions-item>
              <el-descriptions-item label="复合PSF">{{ formatNum(task.composite_psf) }}</el-descriptions-item>
              <el-descriptions-item label="原始HEP">{{ formatNum(task.raw_hep) }}</el-descriptions-item>
              <el-descriptions-item label="调整后HEP">{{ formatNum(task.adjusted_hep) }}</el-descriptions-item>
              <el-descriptions-item label="最终HEP">
                <span style="color: #F56C6C; font-weight: 700; font-size: 16px">{{ formatNum(task.final_hep) }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="负向PSF数量">{{ task.negative_count || 0 }}</el-descriptions-item>
            </el-descriptions>

            <!-- PSF values table -->
            <h4 style="margin-bottom: 8px; color: #606266">PSF乘子表</h4>
            <el-table :data="task.psf_values || []" border size="small" style="margin-bottom: 12px">
              <el-table-column prop="psf_name" label="PSF因素" />
              <el-table-column prop="level_name" label="等级" />
              <el-table-column prop="multiplier" label="乘子值" width="80" align="center">
                <template #default="{ row }">
                  <span :style="{ color: row.multiplier > 1 ? '#F56C6C' : row.multiplier < 1 ? '#67C23A' : '' }">
                    {{ row.multiplier }}
                  </span>
                </template>
              </el-table-column>
            </el-table>
          </div>

          <!-- Joint HEP -->
          <div v-if="detail.joint_hep != null" style="margin-bottom: 16px">
            <el-descriptions :column="1" border size="small">
              <el-descriptions-item label="联合HEP">
                <span style="color: #E6A23C; font-weight: 700; font-size: 16px">{{ formatNum(detail.joint_hep) }}</span>
              </el-descriptions-item>
            </el-descriptions>
          </div>

          <!-- Dependency -->
          <div v-if="detail.dependency" style="margin-bottom: 16px">
            <h4 style="margin-bottom: 8px; color: #606266">依赖性修正</h4>
            <el-descriptions :column="2" border size="small">
              <el-descriptions-item label="依赖等级">{{ detail.dependency.level }}</el-descriptions-item>
              <el-descriptions-item label="修正后HEP">{{ formatNum(detail.dependency.corrected_hep) }}</el-descriptions-item>
            </el-descriptions>
          </div>

          <!-- Uncertainty -->
          <div v-if="detail.uncertainty">
            <h4 style="margin-bottom: 8px; color: #606266">不确定性分析</h4>
            <el-descriptions :column="3" border size="small">
              <el-descriptions-item label="α">{{ formatNum(detail.uncertainty.alpha) }}</el-descriptions-item>
              <el-descriptions-item label="β">{{ formatNum(detail.uncertainty.beta) }}</el-descriptions-item>
              <el-descriptions-item label="均值">{{ formatNum(detail.uncertainty.mean) }}</el-descriptions-item>
              <el-descriptions-item label="P5">{{ formatNum(detail.uncertainty.p05) }}</el-descriptions-item>
              <el-descriptions-item label="P50">{{ formatNum(detail.uncertainty.p50) }}</el-descriptions-item>
              <el-descriptions-item label="P95">{{ formatNum(detail.uncertainty.p95) }}</el-descriptions-item>
            </el-descriptions>
          </div>

          <!-- Evidence chain -->
          <div v-if="detail.references?.length" style="margin-top: 16px">
            <h4 style="margin-bottom: 8px; color: #606266">方法/规则引用</h4>
            <el-table :data="detail.references" border size="small">
              <el-table-column prop="rule_name" label="规则名称" />
              <el-table-column prop="source" label="来源" />
              <el-table-column prop="annotation" label="标注说明" show-overflow-tooltip />
            </el-table>
          </div>
        </el-card>
      </div>

      <!-- RIGHT: 报表导出 -->
      <div class="right-column">
        <el-card shadow="never">
          <template #header>报表导出</template>
          <el-button type="primary" style="width: 100%" @click="handleExport">
            <el-icon><Download /></el-icon> 导出报告
          </el-button>
          <el-button style="width: 100%; margin-top: 12px; margin-left: 0" @click="handlePrint">
            <el-icon><Printer /></el-icon> 打印
          </el-button>
        </el-card>
      </div>
    </div>

    <!-- Charts below three columns -->
    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>PSF影响程度柱状图</template>
          <div ref="psfChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>Beta概率密度函数分布曲线</template>
          <div ref="betaChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRoute } from 'vue-router'
import { Download, Printer } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { getCase } from '../api/analysis'

const route = useRoute()
const loading = ref(false)
const detail = ref({})
const psfChartRef = ref(null)
const betaChartRef = ref(null)
const charts = []

function formatNum(v) {
  if (v == null) return '-'
  return typeof v === 'number' ? v.toExponential(3) : v
}

function betaPDF(x, a, b) {
  const logBeta = lnGamma(a) + lnGamma(b) - lnGamma(a + b)
  if (x <= 0 || x >= 1) return 0
  return Math.exp((a - 1) * Math.log(x) + (b - 1) * Math.log(1 - x) - logBeta)
}

function lnGamma(z) {
  const g = 7
  const c = [0.99999999999980993, 676.5203681218851, -1259.1392167224028, 771.32342877765313, -176.61502916214059, 12.507343278686905, -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7]
  if (z < 0.5) return Math.log(Math.PI / Math.sin(Math.PI * z)) - lnGamma(1 - z)
  z -= 1
  let x = c[0]
  for (let i = 1; i < g + 2; i++) x += c[i] / (z + i)
  const t = z + g + 0.5
  return 0.5 * Math.log(2 * Math.PI) + (z + 0.5) * Math.log(t) - t + Math.log(x)
}

function renderPsfChart(tasks) {
  if (!psfChartRef.value) return
  const allPsfs = []
  for (const t of (tasks || [])) {
    for (const p of (t.psf_values || [])) {
      allPsfs.push({ name: p.psf_name, value: Math.log10(Math.max(p.multiplier, 0.001)), raw: p.multiplier })
    }
  }
  const chart = echarts.init(psfChartRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis', formatter: params => `${params[0].name}: ${allPsfs[params[0].dataIndex]?.raw}` },
    xAxis: { type: 'category', data: allPsfs.map(p => p.name), axisLabel: { interval: 0, rotate: 30, fontSize: 11 } },
    yAxis: { type: 'value', name: 'log₁₀(乘子)' },
    series: [{
      type: 'bar',
      data: allPsfs.map(p => ({
        value: p.value,
        itemStyle: { color: p.value > 0 ? '#F56C6C' : p.value < 0 ? '#67C23A' : '#409EFF' }
      })),
      barMaxWidth: 30
    }],
    grid: { bottom: 80 }
  })
  charts.push(chart)
}

function renderBetaChart(uncertainty) {
  if (!betaChartRef.value || !uncertainty) return
  const { alpha, beta: betaVal, p05, p50, p95 } = uncertainty
  if (!alpha || !betaVal) return

  const xData = []
  const yData = []
  const step = 0.002
  for (let x = step; x < 1; x += step) {
    xData.push(x.toFixed(4))
    yData.push(betaPDF(x, alpha, betaVal))
  }

  const maxY = Math.max(...yData) * 1.1
  const markLines = []
  if (p05 != null) markLines.push({ xAxis: p05.toFixed(4), name: 'P5', lineStyle: { color: '#67C23A' }, label: { formatter: 'P5' } })
  if (p50 != null) markLines.push({ xAxis: p50.toFixed(4), name: 'P50', lineStyle: { color: '#E6A23C' }, label: { formatter: 'P50' } })
  if (p95 != null) markLines.push({ xAxis: p95.toFixed(4), name: 'P95', lineStyle: { color: '#F56C6C' }, label: { formatter: 'P95' } })

  const chart = echarts.init(betaChartRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: xData, name: 'HEP', axisLabel: { interval: Math.floor(xData.length / 6) } },
    yAxis: { type: 'value', name: '概率密度', max: maxY > 0 ? maxY : undefined },
    series: [{
      type: 'line',
      data: yData,
      smooth: true,
      showSymbol: false,
      lineStyle: { color: '#409EFF', width: 2 },
      areaStyle: { color: 'rgba(64,158,255,0.1)' },
      markLine: {
        symbol: 'none',
        data: markLines
      }
    }],
    grid: { bottom: 40 }
  })
  charts.push(chart)
}

function handleExport() {
  ElMessage.success('报告导出中...')
}

function handlePrint() {
  window.print()
}

function handleResize() {
  charts.forEach(c => c.resize())
}

async function fetchDetail() {
  loading.value = true
  try {
    const res = await getCase(route.params.id)
    detail.value = res.data || {}
    renderPsfChart(detail.value.tasks)
    renderBetaChart(detail.value.uncertainty)
  } catch {
    detail.value = {}
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchDetail()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  charts.forEach(c => c.dispose())
})
</script>

<style scoped>
.three-column-layout {
  display: grid;
  grid-template-columns: 300px 1fr 180px;
  gap: 16px;
}

.text-block-sm {
  padding: 8px;
  background: #f5f7fa;
  border-radius: 4px;
  line-height: 1.6;
  color: #606266;
  font-size: 13px;
}

@media (max-width: 1200px) {
  .three-column-layout {
    grid-template-columns: 1fr;
  }
}
</style>
