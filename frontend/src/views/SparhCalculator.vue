<template>
  <div>
    <h2 style="margin-bottom: 16px">SPAR-H 计算器</h2>

    <el-steps :active="currentStep" finish-status="success" align-center style="margin-bottom: 24px">
      <el-step title="事件信息录入" />
      <el-step title="工况与任务选择" />
      <el-step title="PSF赋值" />
      <el-step title="计算结果" />
      <el-step title="可视化展示" />
    </el-steps>

    <!-- Step 1: 事件信息录入 -->
    <el-card v-show="currentStep === 0" shadow="never">
      <el-form :model="eventInfo" label-width="120px" style="max-width: 700px">
        <el-form-item label="电厂名称">
          <el-input v-model="eventInfo.plant_name" placeholder="请输入电厂名称" />
        </el-form-item>
        <el-form-item label="始发事件">
          <el-input v-model="eventInfo.initiating_event" placeholder="请输入始发事件" />
        </el-form-item>
        <el-form-item label="基本事件编码">
          <el-input v-model="eventInfo.basic_event_code" placeholder="请输入基本事件编码" />
        </el-form-item>
        <el-form-item label="分析人员">
          <el-input v-model="eventInfo.analyst" placeholder="请输入分析人员姓名" />
        </el-form-item>
        <el-form-item label="场景描述">
          <el-input v-model="eventInfo.context" type="textarea" :rows="4" placeholder="请描述事件背景与分析场景" />
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Step 2: 工况与任务选择 -->
    <el-card v-show="currentStep === 1" shadow="never">
      <el-form label-width="120px" style="max-width: 600px">
        <el-form-item label="运行工况">
          <el-radio-group v-model="taskConfig.operation_mode">
            <el-radio label="full_power">满功率</el-radio>
            <el-radio label="low_power">低功率/停堆</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="任务类型">
          <el-checkbox-group v-model="taskConfig.task_types">
            <el-checkbox label="diagnosis">诊断</el-checkbox>
            <el-checkbox label="action">动作</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Step 3: PSF赋值 -->
    <el-card v-show="currentStep === 2" shadow="never">
      <div v-for="taskType in taskConfig.task_types" :key="taskType" style="margin-bottom: 24px">
        <h3 style="margin-bottom: 16px; color: #303133">
          {{ taskType === 'diagnosis' ? '诊断任务' : '动作任务' }} — PSF赋值
        </h3>
        <el-row :gutter="16">
          <el-col :span="12" v-for="psf in PSF_DEFINITIONS" :key="`${taskType}-${psf.id}`">
            <el-card shadow="hover" style="margin-bottom: 12px">
              <template #header>
                <span style="font-weight: 600">{{ psf.name }}</span>
              </template>
              <el-select
                v-model="psfSelections[taskType][psf.id]"
                placeholder="请选择等级"
                style="width: 100%"
              >
                <el-option
                  v-for="level in getPsfLevels(psf.id, taskType)"
                  :key="level.name"
                  :label="`${level.name} (×${level.multiplier})`"
                  :value="level.name"
                />
              </el-select>
              <div v-if="psfSelections[taskType][psf.id]" style="margin-top: 8px; font-size: 13px; color: #909399">
                乘子: <span style="color: #409EFF; font-weight: 600">{{ getMultiplier(psf.id, taskType, psfSelections[taskType][psf.id]) }}</span>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- Step 4: 计算结果 -->
    <el-card v-show="currentStep === 3" shadow="never" v-loading="calculating">
      <div v-for="taskType in taskConfig.task_types" :key="`result-${taskType}`" style="margin-bottom: 24px">
        <h3 style="margin-bottom: 16px; color: #303133">
          {{ taskType === 'diagnosis' ? '诊断任务' : '动作任务' }} 计算结果
        </h3>
        <el-descriptions :column="2" border size="small" style="margin-bottom: 12px">
          <el-descriptions-item label="名义HEP">{{ formatSci(calcResult[taskType]?.nominal_hep) }}</el-descriptions-item>
          <el-descriptions-item label="复合PSF">{{ formatSci(calcResult[taskType]?.composite_psf) }}</el-descriptions-item>
          <el-descriptions-item label="负向PSF数量">{{ calcResult[taskType]?.negative_count || 0 }}</el-descriptions-item>
          <el-descriptions-item label="是否调整">{{ calcResult[taskType]?.adjusted ? '是' : '否' }}</el-descriptions-item>
          <el-descriptions-item label="原始HEP">{{ formatSci(calcResult[taskType]?.raw_hep) }}</el-descriptions-item>
          <el-descriptions-item label="调整后HEP">{{ formatSci(calcResult[taskType]?.adjusted_hep) }}</el-descriptions-item>
          <el-descriptions-item label="最终HEP">
            <span style="color: #F56C6C; font-weight: 700; font-size: 18px">{{ formatSci(calcResult[taskType]?.final_hep) }}</span>
          </el-descriptions-item>
        </el-descriptions>

        <h4 style="margin: 12px 0 8px; color: #606266">PSF乘子明细</h4>
        <el-table :data="calcResult[taskType]?.psf_details || []" border size="small">
          <el-table-column prop="psf_name" label="PSF因素" />
          <el-table-column prop="level_name" label="等级" />
          <el-table-column prop="multiplier" label="乘子" width="80" align="center">
            <template #default="{ row }">
              <span :style="{ color: row.multiplier > 1 ? '#F56C6C' : row.multiplier < 1 ? '#67C23A' : '' }">
                {{ row.multiplier }}
              </span>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- Joint HEP -->
      <div v-if="taskConfig.task_types.length === 2 && calcResult.joint_hep != null">
        <el-descriptions :column="1" border size="small" style="margin-bottom: 12px">
          <el-descriptions-item label="联合HEP (诊断×动作)">
            <span style="color: #E6A23C; font-weight: 700; font-size: 18px">{{ formatSci(calcResult.joint_hep) }}</span>
          </el-descriptions-item>
        </el-descriptions>
      </div>

      <!-- Uncertainty -->
      <div v-if="calcResult.uncertainty">
        <h4 style="margin: 12px 0 8px; color: #606266">不确定性分析</h4>
        <el-descriptions :column="3" border size="small">
          <el-descriptions-item label="α">{{ formatSci(calcResult.uncertainty.alpha) }}</el-descriptions-item>
          <el-descriptions-item label="β">{{ formatSci(calcResult.uncertainty.beta) }}</el-descriptions-item>
          <el-descriptions-item label="均值">{{ formatSci(calcResult.uncertainty.mean) }}</el-descriptions-item>
          <el-descriptions-item label="P5">{{ formatSci(calcResult.uncertainty.p05) }}</el-descriptions-item>
          <el-descriptions-item label="P50">{{ formatSci(calcResult.uncertainty.p50) }}</el-descriptions-item>
          <el-descriptions-item label="P95">{{ formatSci(calcResult.uncertainty.p95) }}</el-descriptions-item>
        </el-descriptions>
      </div>

      <!-- Dependency section -->
      <el-divider />
      <h4 style="margin-bottom: 12px; color: #606266">依赖性分析（可选）</h4>
      <el-form :inline="true" style="margin-bottom: 12px">
        <el-form-item label="同一班组">
          <el-switch v-model="depFlags.same_crew" />
        </el-form-item>
        <el-form-item label="同一时间">
          <el-switch v-model="depFlags.same_time" />
        </el-form-item>
        <el-form-item label="同一位置">
          <el-switch v-model="depFlags.same_location" />
        </el-form-item>
        <el-form-item label="相同线索">
          <el-switch v-model="depFlags.same_cues" />
        </el-form-item>
        <el-form-item label="依赖等级">
          <el-select v-model="depFlags.level" style="width: 120px">
            <el-option label="ZD (零)" value="ZD" />
            <el-option label="LD (低)" value="LD" />
            <el-option label="MD (中)" value="MD" />
            <el-option label="HD (高)" value="HD" />
            <el-option label="CD (完全)" value="CD" />
          </el-select>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Step 5: 可视化展示 -->
    <el-card v-show="currentStep === 4" shadow="never">
      <el-row :gutter="16">
        <el-col :span="12">
          <h4 style="margin-bottom: 12px; color: #303133">PSF影响程度柱状图</h4>
          <div ref="psfBarRef" class="chart-container"></div>
        </el-col>
        <el-col :span="12">
          <h4 style="margin-bottom: 12px; color: #303133">Beta概率密度函数分布曲线</h4>
          <div ref="betaPdfRef" class="chart-container"></div>
        </el-col>
      </el-row>

      <el-divider />
      <el-button type="primary" size="large" @click="handleSave" :loading="saving">
        保存为分析案例
      </el-button>
    </el-card>

    <!-- Navigation buttons -->
    <div style="margin-top: 20px; display: flex; justify-content: center; gap: 16px">
      <el-button v-if="currentStep > 0" @click="currentStep--">上一步</el-button>
      <el-button v-if="currentStep < 4" type="primary" @click="handleNext">
        {{ currentStep === 2 ? '开始计算' : '下一步' }}
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch, nextTick, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { sparhCalc, createCase } from '../api/analysis'

const router = useRouter()
const currentStep = ref(0)
const calculating = ref(false)
const saving = ref(false)
const psfBarRef = ref(null)
const betaPdfRef = ref(null)
const charts = []

const eventInfo = reactive({
  plant_name: '',
  initiating_event: '',
  basic_event_code: '',
  analyst: '',
  context: ''
})

const taskConfig = reactive({
  operation_mode: 'full_power',
  task_types: ['diagnosis']
})

const depFlags = reactive({
  same_crew: false,
  same_time: false,
  same_location: false,
  same_cues: false,
  level: 'ZD'
})

const PSF_DEFINITIONS = [
  { id: 'available_time', name: '可用时间' },
  { id: 'stress', name: '压力/应激' },
  { id: 'complexity', name: '复杂度' },
  { id: 'experience', name: '经验/培训' },
  { id: 'procedures', name: '规程' },
  { id: 'ergonomics', name: '工效学/人机界面' },
  { id: 'fitness', name: '职责适宜' },
  { id: 'work_process', name: '工序' }
]

const PSF_LEVELS = {
  available_time: {
    diagnosis: [
      { name: '时间不充足', multiplier: 0 },
      { name: '勉强充足的时间', multiplier: 10 },
      { name: '名义时间', multiplier: 1 },
      { name: '额外时间', multiplier: 0.1 },
      { name: '充足时间', multiplier: 0.01 }
    ],
    action: [
      { name: '时间不充足', multiplier: 0 },
      { name: '勉强充足的时间', multiplier: 10 },
      { name: '名义时间', multiplier: 1 },
      { name: '额外时间', multiplier: 0.1 },
      { name: '充足时间', multiplier: 0.01 }
    ]
  },
  stress: {
    diagnosis: [
      { name: '极端压力', multiplier: 5 },
      { name: '高度压力', multiplier: 2 },
      { name: '名义压力', multiplier: 1 }
    ],
    action: [
      { name: '极端压力', multiplier: 5 },
      { name: '高度压力', multiplier: 2 },
      { name: '名义压力', multiplier: 1 }
    ]
  },
  complexity: {
    diagnosis: [
      { name: '高度复杂', multiplier: 5 },
      { name: '中等复杂', multiplier: 2 },
      { name: '名义复杂度', multiplier: 1 },
      { name: '明显的诊断', multiplier: 0.1 }
    ],
    action: [
      { name: '高度复杂', multiplier: 5 },
      { name: '中等复杂', multiplier: 2 },
      { name: '名义复杂度', multiplier: 1 }
    ]
  },
  experience: {
    diagnosis: [
      { name: '低经验/培训', multiplier: 10 },
      { name: '名义经验', multiplier: 1 },
      { name: '高经验/培训', multiplier: 0.5 }
    ],
    action: [
      { name: '低经验/培训', multiplier: 3 },
      { name: '名义经验', multiplier: 1 },
      { name: '高经验/培训', multiplier: 0.5 }
    ]
  },
  procedures: {
    diagnosis: [
      { name: '无可用规程', multiplier: 50 },
      { name: '规程不完整', multiplier: 20 },
      { name: '名义规程', multiplier: 1 },
      { name: '诊断型规程', multiplier: 0.5 }
    ],
    action: [
      { name: '无可用规程', multiplier: 50 },
      { name: '规程不完整', multiplier: 20 },
      { name: '名义规程', multiplier: 1 }
    ]
  },
  ergonomics: {
    diagnosis: [
      { name: '差的人机界面', multiplier: 10 },
      { name: '名义界面', multiplier: 1 },
      { name: '良好的界面', multiplier: 0.5 }
    ],
    action: [
      { name: '差的人机界面', multiplier: 10 },
      { name: '名义界面', multiplier: 1 },
      { name: '良好的界面', multiplier: 0.5 }
    ]
  },
  fitness: {
    diagnosis: [
      { name: '不适宜', multiplier: 0 },
      { name: '降低的适宜性', multiplier: 5 },
      { name: '名义适宜', multiplier: 1 }
    ],
    action: [
      { name: '不适宜', multiplier: 0 },
      { name: '降低的适宜性', multiplier: 5 },
      { name: '名义适宜', multiplier: 1 }
    ]
  },
  work_process: {
    diagnosis: [
      { name: '差的工序', multiplier: 2 },
      { name: '名义工序', multiplier: 1 },
      { name: '良好的工序', multiplier: 0.8 }
    ],
    action: [
      { name: '差的工序', multiplier: 5 },
      { name: '名义工序', multiplier: 1 },
      { name: '良好的工序', multiplier: 0.8 }
    ]
  }
}

const psfSelections = reactive({
  diagnosis: {},
  action: {}
})

const calcResult = reactive({
  diagnosis: null,
  action: null,
  joint_hep: null,
  uncertainty: null
})

function getPsfLevels(psfId, taskType) {
  return PSF_LEVELS[psfId]?.[taskType] || []
}

function getMultiplier(psfId, taskType, levelName) {
  const level = getPsfLevels(psfId, taskType).find(l => l.name === levelName)
  return level ? level.multiplier : 1
}

function formatSci(v) {
  if (v == null) return '-'
  if (typeof v !== 'number') return v
  if (v === 0) return '0'
  return v < 0.001 || v > 10000 ? v.toExponential(4) : v.toFixed(6)
}

function buildPsfArray(taskType) {
  return PSF_DEFINITIONS.map(psf => {
    const levelName = psfSelections[taskType][psf.id] || '名义'
    const levels = getPsfLevels(psf.id, taskType)
    const matched = levels.find(l => l.name === levelName)
    return {
      psf_id: psf.id,
      psf_name: psf.name,
      level_name: levelName,
      multiplier: matched ? matched.multiplier : 1
    }
  })
}

function localCalculate(taskType) {
  const nominalHep = taskType === 'diagnosis' ? 0.01 : 0.001
  const psfDetails = buildPsfArray(taskType)
  const multipliers = psfDetails.map(p => p.multiplier)

  if (multipliers.includes(0)) {
    return { nominal_hep: nominalHep, composite_psf: 0, raw_hep: 1.0, adjusted_hep: 1.0, final_hep: 1.0, negative_count: 0, adjusted: false, psf_details: psfDetails }
  }

  const compositePsf = multipliers.reduce((a, b) => a * b, 1)
  const negativeCount = multipliers.filter(m => m > 1).length
  let rawHep = nominalHep * compositePsf
  let adjustedHep = rawHep
  let adjusted = false

  if (negativeCount >= 3) {
    adjustedHep = nominalHep * compositePsf / (nominalHep * (compositePsf - 1) + 1)
    adjusted = true
  }

  const finalHep = Math.min(adjustedHep, 1.0)

  return { nominal_hep: nominalHep, composite_psf: compositePsf, raw_hep: rawHep, adjusted_hep: adjustedHep, final_hep: finalHep, negative_count: negativeCount, adjusted, psf_details: psfDetails }
}

function localUncertainty(hep) {
  if (!hep || hep <= 0 || hep >= 1) return null
  const mean = hep
  const ef = 5
  const p05 = mean / ef
  const p95 = Math.min(mean * ef, 1.0)
  const p50 = mean

  const variance = mean * (1 - mean) / (ef * ef)
  const alpha = mean * (mean * (1 - mean) / variance - 1)
  const beta = (1 - mean) * (mean * (1 - mean) / variance - 1)

  return {
    alpha: Math.max(alpha, 0.01),
    beta: Math.max(beta, 0.01),
    mean, p05, p50, p95
  }
}

async function runCalculation() {
  calculating.value = true
  try {
    const tasks = taskConfig.task_types.map(tt => ({
      task_type: tt,
      psf_values: buildPsfArray(tt)
    }))

    const payload = {
      operation_mode: taskConfig.operation_mode,
      tasks,
      ...eventInfo
    }

    try {
      const res = await sparhCalc(payload)
      if (res.code === 200 && res.data) {
        for (const tt of taskConfig.task_types) {
          calcResult[tt] = res.data[tt] || localCalculate(tt)
        }
        calcResult.joint_hep = res.data.joint_hep ?? null
        calcResult.uncertainty = res.data.uncertainty ?? null
        return
      }
    } catch {
      ElMessage.warning('Flask服务不可用，使用本地计算')
    }

    for (const tt of taskConfig.task_types) {
      calcResult[tt] = localCalculate(tt)
    }

    if (taskConfig.task_types.length === 2) {
      const dHep = calcResult.diagnosis?.final_hep || 0
      const aHep = calcResult.action?.final_hep || 0
      calcResult.joint_hep = dHep * aHep
    }

    const finalHep = calcResult.joint_hep || calcResult[taskConfig.task_types[0]]?.final_hep
    calcResult.uncertainty = localUncertainty(finalHep)
  } finally {
    calculating.value = false
  }
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

function betaPDF(x, a, b) {
  if (x <= 0 || x >= 1) return 0
  const logBeta = lnGamma(a) + lnGamma(b) - lnGamma(a + b)
  return Math.exp((a - 1) * Math.log(x) + (b - 1) * Math.log(1 - x) - logBeta)
}

function renderVisCharts() {
  const allPsfs = []
  for (const tt of taskConfig.task_types) {
    const details = calcResult[tt]?.psf_details || []
    const prefix = tt === 'diagnosis' ? '[诊断]' : '[动作]'
    for (const p of details) {
      allPsfs.push({ name: `${prefix}${p.psf_name}`, multiplier: p.multiplier })
    }
  }

  if (psfBarRef.value) {
    const chart = echarts.init(psfBarRef.value)
    chart.setOption({
      tooltip: { trigger: 'axis', formatter: params => `${params[0].name}: ${allPsfs[params[0].dataIndex]?.multiplier}` },
      xAxis: { type: 'category', data: allPsfs.map(p => p.name), axisLabel: { interval: 0, rotate: 45, fontSize: 10 } },
      yAxis: { type: 'value', name: 'log₁₀(乘子)' },
      series: [{
        type: 'bar',
        data: allPsfs.map(p => ({
          value: Math.log10(Math.max(p.multiplier, 0.001)),
          itemStyle: { color: p.multiplier > 1 ? '#F56C6C' : p.multiplier < 1 ? '#67C23A' : '#409EFF' }
        })),
        barMaxWidth: 25
      }],
      grid: { bottom: 100 }
    })
    charts.push(chart)
  }

  if (betaPdfRef.value && calcResult.uncertainty) {
    const { alpha, beta: betaVal, p05, p50, p95 } = calcResult.uncertainty
    if (alpha && betaVal) {
      const xData = []
      const yData = []
      const step = 0.002
      for (let x = step; x < 1; x += step) {
        xData.push(x.toFixed(4))
        yData.push(betaPDF(x, alpha, betaVal))
      }

      const maxY = Math.max(...yData) * 1.1
      const markLines = []
      if (p05 != null) markLines.push({ xAxis: p05.toFixed(4), name: 'P5', lineStyle: { color: '#67C23A', type: 'dashed' }, label: { formatter: 'P5', position: 'end' } })
      if (p50 != null) markLines.push({ xAxis: p50.toFixed(4), name: 'P50', lineStyle: { color: '#E6A23C', type: 'dashed' }, label: { formatter: 'P50', position: 'end' } })
      if (p95 != null) markLines.push({ xAxis: p95.toFixed(4), name: 'P95', lineStyle: { color: '#F56C6C', type: 'dashed' }, label: { formatter: 'P95', position: 'end' } })

      const chart = echarts.init(betaPdfRef.value)
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
          markLine: { symbol: 'none', data: markLines }
        }],
        grid: { bottom: 40 }
      })
      charts.push(chart)
    }
  }
}

async function handleNext() {
  if (currentStep.value === 2) {
    await runCalculation()
    currentStep.value = 3
  } else if (currentStep.value === 3) {
    currentStep.value = 4
    await nextTick()
    renderVisCharts()
  } else {
    currentStep.value++
  }
}

async function handleSave() {
  saving.value = true
  try {
    const payload = {
      case_name: `SPAR-H: ${eventInfo.initiating_event || eventInfo.basic_event_code || '新计算'}`,
      analysis_method: 'SPAR-H',
      analyst: eventInfo.analyst,
      plant_name: eventInfo.plant_name,
      initiating_event: eventInfo.initiating_event,
      basic_event: eventInfo.basic_event_code,
      operation_condition: taskConfig.operation_mode === 'full_power' ? '满功率' : '低功率/停堆',
      context_description: eventInfo.context,
      tasks: taskConfig.task_types.map(tt => ({
        task_type: tt,
        ...calcResult[tt]
      })),
      joint_hep: calcResult.joint_hep,
      uncertainty: calcResult.uncertainty
    }
    await createCase(payload)
    ElMessage.success('已保存为分析案例')
    router.push('/analysis')
  } catch {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

watch(() => taskConfig.task_types, (val) => {
  for (const tt of val) {
    if (!psfSelections[tt]) psfSelections[tt] = {}
    for (const psf of PSF_DEFINITIONS) {
      if (!psfSelections[tt][psf.id]) {
        const levels = getPsfLevels(psf.id, tt)
        const nominal = levels.find(l => l.multiplier === 1)
        psfSelections[tt][psf.id] = nominal?.name || levels[0]?.name || ''
      }
    }
  }
}, { immediate: true })

onBeforeUnmount(() => {
  charts.forEach(c => c.dispose())
})
</script>
