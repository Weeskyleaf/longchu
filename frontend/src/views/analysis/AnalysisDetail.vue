<template>
  <div class="analysis-detail" v-loading="loading">
    <div class="page-header">
      <el-button @click="$router.back()" text>
        <el-icon><ArrowLeft /></el-icon> 返回列表
      </el-button>
      <h2>{{ caseData.case_name || '分析案例详情' }}</h2>
      <el-tag :type="statusType" style="margin-left: 12px">{{ statusLabel }}</el-tag>
    </div>

    <!-- 三栏布局 -->
    <el-row :gutter="16">
      <!-- 左：案例信息 -->
      <el-col :span="6">
        <el-card shadow="never" class="info-card">
          <template #header><span class="card-title">案例信息</span></template>
          <el-descriptions :column="1" size="small" direction="vertical">
            <el-descriptions-item label="案例编号">{{ caseData.case_code }}</el-descriptions-item>
            <el-descriptions-item label="案例名称">{{ caseData.case_name }}</el-descriptions-item>
            <el-descriptions-item label="分析方法">{{ caseData.method_code }}</el-descriptions-item>
            <el-descriptions-item label="分析路径">{{ caseData.analysis_path }}</el-descriptions-item>
            <el-descriptions-item label="分析人员">{{ caseData.analyst }}</el-descriptions-item>
            <el-descriptions-item label="创建时间">{{ formatDate(caseData.created_at) }}</el-descriptions-item>
          </el-descriptions>
          <div v-if="caseData.summary" style="margin-top: 12px">
            <div style="font-size: 12px; color: #909399; margin-bottom: 4px">案例摘要</div>
            <div style="font-size: 13px; color: #606266; line-height: 1.6">{{ caseData.summary }}</div>
          </div>
        </el-card>
      </el-col>

      <!-- 中：计算结果 -->
      <el-col :span="12">
        <el-card shadow="never" class="result-card">
          <template #header><span class="card-title">计算结果</span></template>

          <div v-if="caseTasks.length === 0" class="empty-hint">
            <el-empty description="暂无计算结果，请先执行计算" />
          </div>

          <div v-for="task in caseTasks" :key="task.id" class="task-result">
            <h4 class="task-type-title">
              <el-icon><SetUp /></el-icon>
              {{ task.task_type === 'diagnosis' ? '诊断任务' : '动作任务' }}
            </h4>

            <!-- PSF赋值表 -->
            <el-table :data="task.psf_values || []" stripe border size="small" style="margin-bottom: 16px">
              <el-table-column prop="psf_name" label="PSF因子" width="140" />
              <el-table-column prop="level_name" label="赋值等级" width="130" />
              <el-table-column prop="multiplier" label="乘数" width="100" align="center">
                <template #default="{ row }">
                  <span :class="{ 'negative-val': row.is_negative }">{{ row.multiplier }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="basis_text" label="依据" show-overflow-tooltip />
            </el-table>

            <!-- HEP结果 -->
            <el-descriptions :column="2" border size="small">
              <el-descriptions-item label="名义HEP">{{ fmtSci(task.nominal_hep) }}</el-descriptions-item>
              <el-descriptions-item label="复合PSF">{{ fmtNum(task.composite_psf) }}</el-descriptions-item>
              <el-descriptions-item label="原始HEP">{{ fmtSci(task.raw_hep) }}</el-descriptions-item>
              <el-descriptions-item label="调整后HEP">{{ fmtSci(task.adjusted_hep) }}</el-descriptions-item>
              <el-descriptions-item label="负向因子数">{{ task.negative_count }}</el-descriptions-item>
              <el-descriptions-item label="最终HEP">
                <span class="final-hep">{{ fmtSci(task.final_hep) }}</span>
              </el-descriptions-item>
            </el-descriptions>

            <!-- 不确定性 -->
            <div v-if="task.uncertainty" class="uncertainty-section">
              <h5>不确定性分析</h5>
              <el-descriptions :column="3" border size="small">
                <el-descriptions-item label="分布类型">{{ task.uncertainty.dist_type || 'Beta' }}</el-descriptions-item>
                <el-descriptions-item label="α参数">{{ fmtNum(task.uncertainty.alpha_param) }}</el-descriptions-item>
                <el-descriptions-item label="β参数">{{ fmtNum(task.uncertainty.beta_param) }}</el-descriptions-item>
                <el-descriptions-item label="P5">{{ fmtSci(task.uncertainty.p05) }}</el-descriptions-item>
                <el-descriptions-item label="P50">{{ fmtSci(task.uncertainty.p50) }}</el-descriptions-item>
                <el-descriptions-item label="P95">{{ fmtSci(task.uncertainty.p95) }}</el-descriptions-item>
              </el-descriptions>
            </div>
          </div>

          <!-- 联合HEP -->
          <div v-if="jointHep !== null" class="joint-section">
            <el-divider />
            <el-descriptions :column="1" border size="small">
              <el-descriptions-item label="联合HEP (Joint HEP)">
                <span class="final-hep">{{ fmtSci(jointHep) }}</span>
              </el-descriptions-item>
            </el-descriptions>
          </div>

          <!-- 相关性 -->
          <div v-if="dependency" class="dep-section">
            <el-divider />
            <h4><el-icon><Connection /></el-icon> 相关性评估</h4>
            <el-descriptions :column="2" border size="small">
              <el-descriptions-item label="相关性等级">{{ dependency.dependency_level }}</el-descriptions-item>
              <el-descriptions-item label="修正值">{{ fmtNum(dependency.correction_value) }}</el-descriptions-item>
              <el-descriptions-item label="同一班组">{{ dependency.same_crew_flag ? '是' : '否' }}</el-descriptions-item>
              <el-descriptions-item label="时间接近">{{ dependency.close_in_time_flag ? '是' : '否' }}</el-descriptions-item>
              <el-descriptions-item label="同一地点">{{ dependency.same_location_flag ? '是' : '否' }}</el-descriptions-item>
              <el-descriptions-item label="相同线索">{{ dependency.same_cues_flag ? '是' : '否' }}</el-descriptions-item>
            </el-descriptions>
          </div>
        </el-card>
      </el-col>

      <!-- 右：证据索引 -->
      <el-col :span="6">
        <el-card shadow="never" class="evidence-card">
          <template #header><span class="card-title">证据索引</span></template>
          <div v-if="evidenceList.length === 0" class="empty-hint">
            <el-empty description="暂无证据记录" :image-size="60" />
          </div>
          <el-timeline v-else>
            <el-timeline-item v-for="ev in evidenceList" :key="ev.id" :timestamp="ev.trace_step" placement="top">
              <div class="ev-item">
                <div class="ev-source">{{ ev.source_table }} #{{ ev.source_pk }}</div>
                <div class="ev-excerpt" v-if="ev.evidence_excerpt">{{ ev.evidence_excerpt }}</div>
                <div class="ev-recorder" v-if="ev.recorder">记录人: {{ ev.recorder }}</div>
              </div>
            </el-timeline-item>
          </el-timeline>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="16" style="margin-top: 16px" v-if="caseTasks.length > 0">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header><span class="card-title">PSF影响因素柱状图</span></template>
          <div ref="psfChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <template #header><span class="card-title">Beta概率分布曲线</span></template>
          <div ref="betaChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { getCase } from '@/api/analysis'
import * as echarts from 'echarts'

const route = useRoute()
const caseId = route.params.id

const loading = ref(false)
const caseData = ref({})
const caseTasks = ref([])
const evidenceList = ref([])
const dependency = ref(null)
const jointHep = ref(null)

const psfChartRef = ref(null)
const betaChartRef = ref(null)
let charts = []

const statusMap = { draft: { label: '草稿', type: 'info' }, pending: { label: '待审核', type: 'warning' }, approved: { label: '已审核', type: 'success' } }
const statusType = computed(() => statusMap[caseData.value.review_status]?.type || 'info')
const statusLabel = computed(() => statusMap[caseData.value.review_status]?.label || caseData.value.review_status || '')

function formatDate(v) { return v ? v.replace('T', ' ').substring(0, 16) : '' }
function fmtSci(v) { return v != null ? Number(v).toExponential(3) : '-' }
function fmtNum(v) { return v != null ? Number(v).toFixed(4) : '-' }

function betaPdf(x, a, b) {
  if (x <= 0 || x >= 1) return 0
  const lnBeta = lnGamma(a) + lnGamma(b) - lnGamma(a + b)
  return Math.exp((a - 1) * Math.log(x) + (b - 1) * Math.log(1 - x) - lnBeta)
}

function lnGamma(z) {
  const c = [76.18009172947146, -86.50532032941678, 24.01409824083091, -1.231739572450155, 0.001208650973866179, -0.000005395239384953]
  let x = z, y = z
  let tmp = x + 5.5
  tmp -= (x + 0.5) * Math.log(tmp)
  let ser = 1.000000000190015
  for (let j = 0; j < 6; j++) ser += c[j] / ++y
  return -tmp + Math.log(2.5066282746310005 * ser / x)
}

function renderCharts() {
  if (!caseTasks.value.length) return

  const psfNames = ['时间', '压力', '复杂度', '经验培训', '规程', '工效学', '职责适宜', '工序']
  const seriesData = []

  for (const task of caseTasks.value) {
    const multipliers = psfNames.map((name) => {
      const found = (task.psf_values || []).find(p => p.psf_name?.includes(name))
      return found ? Number(found.multiplier) : 1
    })
    seriesData.push({
      name: task.task_type === 'diagnosis' ? '诊断' : '动作',
      type: 'bar',
      data: multipliers,
    })
  }

  const psfChart = echarts.init(psfChartRef.value)
  psfChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: {},
    xAxis: { type: 'category', data: psfNames, axisLabel: { rotate: 30 } },
    yAxis: { type: 'log', name: '乘数 (对数轴)', min: 0.01 },
    color: ['#409EFF', '#67C23A'],
    series: seriesData,
    grid: { left: 60, right: 20, top: 40, bottom: 50 },
  })
  charts.push(psfChart)

  const firstUncertainty = caseTasks.value.find(t => t.uncertainty)?.uncertainty
  if (firstUncertainty?.alpha_param && firstUncertainty?.beta_param) {
    const a = Number(firstUncertainty.alpha_param)
    const b = Number(firstUncertainty.beta_param)
    const xData = []
    const yData = []
    for (let i = 1; i < 200; i++) {
      const x = i / 200
      xData.push(x.toFixed(3))
      yData.push(betaPdf(x, a, b))
    }

    const betaChart = echarts.init(betaChartRef.value)
    betaChart.setOption({
      tooltip: { trigger: 'axis' },
      xAxis: { type: 'category', data: xData, name: 'HEP', axisLabel: { interval: 39 } },
      yAxis: { type: 'value', name: '概率密度' },
      series: [{
        type: 'line',
        data: yData,
        smooth: true,
        showSymbol: false,
        lineStyle: { width: 2, color: '#E6A23C' },
        areaStyle: { color: 'rgba(230,162,60,0.15)' },
      }],
      grid: { left: 60, right: 20, top: 30, bottom: 40 },
      graphic: firstUncertainty.p05 != null ? [{
        type: 'group',
        left: 'center',
        bottom: 5,
        children: [{
          type: 'text',
          style: {
            text: `P5=${fmtSci(firstUncertainty.p05)}  P50=${fmtSci(firstUncertainty.p50)}  P95=${fmtSci(firstUncertainty.p95)}`,
            fontSize: 12, fill: '#606266',
          },
        }],
      }] : [],
    })
    charts.push(betaChart)
  }
}

async function loadData() {
  loading.value = true
  try {
    const res = await getCase(caseId)
    const d = res.data || res || {}
    caseData.value = d
    caseTasks.value = d.tasks || []
    evidenceList.value = d.evidence || []
    dependency.value = d.dependency || null
    jointHep.value = d.joint_hep ?? null
    await nextTick()
    renderCharts()
  } catch { /* handled */ } finally {
    loading.value = false
  }
}

function handleResize() { charts.forEach(c => c.resize()) }

onMounted(() => {
  loadData()
  window.addEventListener('resize', handleResize)
})
onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  charts.forEach(c => c.dispose())
})
</script>

<style scoped>
.analysis-detail { display: flex; flex-direction: column; gap: 16px; }
.page-header { display: flex; align-items: center; gap: 12px; }
.page-header h2 { font-size: 20px; color: #303133; margin: 0; }
.card-title { font-weight: 600; font-size: 15px; color: #303133; }
.task-result { margin-bottom: 24px; }
.task-type-title {
  display: flex; align-items: center; gap: 6px;
  font-size: 15px; color: #303133; margin-bottom: 12px;
  padding-bottom: 8px; border-bottom: 1px solid #ebeef5;
}
.final-hep { font-weight: 700; color: #F56C6C; font-size: 15px; }
.negative-val { color: #F56C6C; font-weight: 600; }
.uncertainty-section { margin-top: 12px; }
.uncertainty-section h5 { font-size: 13px; color: #606266; margin-bottom: 8px; }
.joint-section, .dep-section { margin-top: 8px; }
.dep-section h4 { display: flex; align-items: center; gap: 6px; font-size: 14px; color: #303133; margin-bottom: 8px; }
.empty-hint { padding: 20px 0; }
.ev-item { font-size: 13px; }
.ev-source { color: #409EFF; font-weight: 500; }
.ev-excerpt { color: #606266; margin-top: 4px; }
.ev-recorder { color: #909399; font-size: 12px; margin-top: 2px; }
.chart-box { height: 340px; }
.info-card, .evidence-card { height: 100%; }
</style>
