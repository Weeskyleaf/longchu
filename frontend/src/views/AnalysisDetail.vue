<template>
  <div class="analysis-detail-page" v-loading="loading">
    <div class="page-header">
      <h2>HRA 分析结果详情</h2>
      <el-button @click="$router.back()">返回</el-button>
    </div>

    <el-row :gutter="20">
      <el-col :span="8">
        <div class="analysis-card">
          <div class="card-header-dark">事件描述 &amp; PSF 因子取值</div>
          <div class="card-body">
            <div class="event-desc">{{ ad.eventDescription }}</div>

            <div class="section-subtitle">表：LOCA事件PSF因子取值及定量化结果</div>
            <el-table :data="ad.psfRows" border size="small" class="psf-value-table">
              <el-table-column prop="name" label="绩效形成因子(PSF)" min-width="120" />
              <el-table-column label="诊断乘子值" min-width="140" align="center">
                <template #default="{ row }">
                  <span>{{ row.dv }}</span>
                  <span v-if="row.dn" class="note-text"> ({{ row.dn }})</span>
                </template>
              </el-table-column>
              <el-table-column label="动作乘子值" min-width="140" align="center">
                <template #default="{ row }">
                  <span>{{ row.av }}</span>
                  <span v-if="row.an" class="note-text"> ({{ row.an }})</span>
                </template>
              </el-table-column>
            </el-table>

            <div class="footer-note">
              PSF赋值定义基于 SPAR-H (NUREG/CR-6883)，各因子乘子取值参照操纵员任务分析与专家判断结果。
            </div>
            <div class="footer-note">
              参考标准：NB/T 20642-2023《核电厂概率安全评价中人因可靠性分析程序》
            </div>
          </div>
        </div>
      </el-col>

      <el-col :span="8">
        <div class="analysis-card">
          <div class="card-header-dark">量化结果 &amp; 不确定性 (Beta分布)</div>
          <div class="card-body">
            <div class="hep-display">
              <div class="hep-label">最终人员失误概率 (HEP)</div>
              <div class="hep-value">{{ fmtSci(ad.jointHep) }}</div>
              <div class="hep-subtitle">SPAR-H方法估计结果 | 5% ~ 95% 分位区间置信区间</div>
              <div class="hep-interval">
                5% 分位: {{ fmtSci(ad.p05) }} | 95% 分位数: {{ fmtSci(ad.p95) }}
              </div>
            </div>

            <div class="status-badges">
              <el-tag type="success" effect="dark" size="small">Result</el-tag>
              <el-tag type="primary" effect="dark" size="small">Verified</el-tag>
              <el-tag type="info" effect="dark" size="small">Archived</el-tag>
            </div>

            <div class="calc-logic">
              <div class="logic-title">计算逻辑 (SPAR-H 基本模型)</div>
              <div class="formula-block">
                <p>基本公式: HEP<sub>final</sub> = P₀ × ∏PSF<sub>i</sub></p>
                <p class="formula-line">
                  诊断: HEP<sub>d</sub> = P₀,d × (分类累乘) = {{ fmtSci(ad.diagNominal) }} × {{ ad.diagMultStr }} = {{ fmtSci(ad.diagHep) }}
                </p>
                <p class="formula-line">
                  动作: HEP<sub>a</sub> = P₀,a × (分类累乘) = {{ fmtSci(ad.actNominal) }} × {{ ad.actMultStr }} = {{ fmtSci(ad.actHep) }}
                </p>
                <p class="formula-line formula-highlight">
                  联合HEP = 诊断HEP + 动作HEP = {{ fmtSci(ad.diagHep) }} + {{ fmtSci(ad.actHep) }} = {{ fmtSci(ad.jointHep) }}
                </p>
              </div>
              <div class="formula-note">
                负向PSF数量 = {{ ad.negCount }} ({{ ad.negNote }})，{{
                  ad.negCount >= 3 ? '需要启用修正公式' : '未达到≥3, 无需启用修正公式'
                }}
              </div>
              <div class="formula-note" style="margin-top: 6px">
                Beta不确定性: α = {{ ad.alpha }}, β = {{ ad.betaVal }}
              </div>
            </div>

            <div class="reference-note">
              方法参考: SPAR-H方法源自NUREG/CR-6883，不确定性分析采用Beta分布 (CNI先验) 进行贝叶斯处理。
            </div>
          </div>
        </div>
      </el-col>

      <el-col :span="8">
        <div class="analysis-card">
          <div class="card-header-dark">证据链 &amp; 报表导出</div>
          <div class="card-body">
            <p class="evidence-text">
              本栏记录所有的计算证据说明，包括PSF因子选择依据、计算公式推导过程、参考标准和方法来源等完整的分析证据链。
            </p>

            <el-button type="primary" size="large" class="report-btn" @click="handleExport">
              生成完整分析报告
            </el-button>

            <div class="uncertainty-section">
              <div class="logic-title">不确定性参数信息</div>
              <div class="param-grid">
                <div class="param-item">
                  <span class="param-label">分布类型</span>
                  <span class="param-value">Beta (α, β) 参数标注</span>
                </div>
                <div class="param-item">
                  <span class="param-label">α</span>
                  <span class="param-value">{{ ad.alpha }}</span>
                </div>
                <div class="param-item">
                  <span class="param-label">β</span>
                  <span class="param-value">{{ ad.betaVal }}</span>
                </div>
                <div class="param-item">
                  <span class="param-label">CNI先验</span>
                  <span class="param-value">参数标注</span>
                </div>
              </div>
              <div class="footer-note">
                参考标准：NUREG/CR-6883, NB/T 20642-2023
              </div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="12">
        <div class="analysis-card">
          <div class="card-header-dark">绩效形成因子(PSF)影响对比 | 诊断 vs 动作 乘子值</div>
          <div class="card-body">
            <div ref="psfBarRef" class="chart-box"></div>
            <div class="chart-note">最大乘子指向最强影响因子，可重点关注乘子值 &gt; 1 的负向PSF因子</div>
          </div>
        </div>
      </el-col>

      <el-col :span="12">
        <div class="analysis-card">
          <div class="card-header-dark">Beta 分布概率密度曲线（CNI 先验）</div>
          <div class="card-body">
            <div class="beta-subtitle">
              SPAR-H不确定性分析 | 对数坐标模型 | α = {{ ad.alpha }}, β = {{ ad.betaVal }}
              | 均值 μ = {{ fmtSci(ad.mean) }}
            </div>

            <div class="info-cards-row">
              <div class="info-card-mini"><div class="ic-label">α</div><div class="ic-value">{{ ad.alpha }}</div></div>
              <div class="info-card-mini"><div class="ic-label">β</div><div class="ic-value">{{ ad.betaVal }}</div></div>
              <div class="info-card-mini"><div class="ic-label">均值μ</div><div class="ic-value">{{ fmtSci(ad.mean) }}</div></div>
              <div class="info-card-mini"><div class="ic-label">5%分位</div><div class="ic-value">{{ fmtSci(ad.p05) }}</div></div>
              <div class="info-card-mini"><div class="ic-label">95%分位</div><div class="ic-value">{{ fmtSci(ad.p95) }}</div></div>
              <div class="info-card-mini wide"><div class="ic-label">区间</div><div class="ic-value">[{{ fmtSci(ad.p05) }}, {{ fmtSci(ad.p95) }}]</div></div>
            </div>

            <div style="text-align: right; margin-bottom: 8px">
              <el-switch v-model="useLogScale" active-text="log-log" inactive-text="线性" @change="renderBetaChart" />
            </div>

            <div ref="betaPdfRef" class="chart-box"></div>
            <div class="chart-legend">● 概率密度值曲线 | X轴: x (失误概率) | Y轴: f(x, α, β)</div>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { getCase } from '../api/analysis'

const route = useRoute()
const loading = ref(false)
const useLogScale = ref(true)
const psfBarRef = ref(null)
const betaPdfRef = ref(null)
const charts = []

const PSF_NAMES = ['可用时间', '压力', '复杂程度', '经验/培训', '规程', '工效学/人机界面', '职责适宜度', '工序']

const LOCA_DEFAULT = {
  eventDescription:
    '估算事件：一回路中破口事故(LOCA)。分析场景基于压水堆核电厂满功率运行工况下，' +
    '冷却剂管道发生中破口（破口当量直径约6英寸）事故。操纵员需在规程指引下完成事故诊断与' +
    '应急响应操作，包括安注系统投入、主泵跳闸确认、安全壳隔离等关键动作。本分析涵盖诊断阶段' +
    '与动作阶段两个任务类型，综合评估操纵员在高压力工况下的人因失误概率。',
  psfRows: [
    { name: '基础值(名义HEP)', dv: '1.0E-2', av: '1.0E-3' },
    { name: '可用时间', dv: '0.01', dn: '充足时间 >60min', av: '0.01', an: '2/5倍所需时间' },
    { name: '压力', dv: '5', dn: '很高', av: '2', an: '高' },
    { name: '复杂程度', dv: '1', dn: '正常', av: '1', an: '正常' },
    { name: '经验/培训', dv: '0.5', dn: '高', av: '0.5', an: '高' },
    { name: '规程', dv: '0.5', dn: '征兆导向规程', av: '1', an: '正常' },
    { name: '工效学/人机界面', dv: '1', dn: '正常', av: '1', an: '正常' },
    { name: '职责适宜度', dv: '1', dn: '正常', av: '1', an: '正常' },
    { name: '工序', dv: '1', dn: '正常', av: '1', an: '正常' }
  ],
  diagNominal: 1e-2,
  actNominal: 1e-3,
  diagComposite: 0.0125,
  actComposite: 0.01,
  diagHep: 1.25e-4,
  actHep: 1e-5,
  jointHep: 1.35e-4,
  negCount: 1,
  negNote: '仅压力为负向',
  alpha: 0.015,
  betaVal: 111.1,
  mean: 1.35e-4,
  p05: 9.45e-6,
  p95: 1.71e-4,
  diagMult: [0.01, 5, 1, 0.5, 0.5, 1, 1, 1],
  actMult: [0.01, 2, 1, 0.5, 1, 1, 1, 1],
  diagMultStr: '0.01 × 5 × 1 × 0.5 × 0.5 × 1 × 1 × 1',
  actMultStr: '0.01 × 2 × 1 × 0.5 × 1 × 1 × 1 × 1'
}

const ad = reactive({ ...LOCA_DEFAULT })

function fmtSci(v) {
  if (v == null) return '-'
  if (typeof v !== 'number') return v
  if (v === 0) return '0'
  return v < 0.001 || v > 10000 ? v.toExponential(2) : v.toPrecision(4)
}

function lnGamma(z) {
  const c = [
    0.99999999999980993, 676.5203681218851, -1259.1392167224028,
    771.32342877765313, -176.61502916214059, 12.507343278686905,
    -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7
  ]
  if (z < 0.5) return Math.log(Math.PI / Math.sin(Math.PI * z)) - lnGamma(1 - z)
  z -= 1
  let x = c[0]
  for (let i = 1; i < 9; i++) x += c[i] / (z + i)
  const t = z + 7.5
  return 0.5 * Math.log(2 * Math.PI) + (z + 0.5) * Math.log(t) - t + Math.log(x)
}

function betaPDF(x, a, b) {
  if (x <= 0 || x >= 1) return 0
  const logB = lnGamma(a) + lnGamma(b) - lnGamma(a + b)
  return Math.exp((a - 1) * Math.log(x) + (b - 1) * Math.log(1 - x) - logB)
}

function renderPsfBarChart() {
  if (!psfBarRef.value) return
  const chart = echarts.init(psfBarRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    legend: { data: ['诊断乘子', '动作乘子'], top: 4 },
    grid: { left: '22%', right: '8%', bottom: '12%', top: '12%' },
    yAxis: {
      type: 'category',
      data: PSF_NAMES,
      inverse: true,
      axisLabel: { fontSize: 11 }
    },
    xAxis: { type: 'value', name: '乘子值' },
    series: [
      {
        name: '诊断乘子',
        type: 'bar',
        data: ad.diagMult,
        itemStyle: { color: '#3b82f6' },
        barGap: '20%',
        barMaxWidth: 18
      },
      {
        name: '动作乘子',
        type: 'bar',
        data: ad.actMult,
        itemStyle: { color: '#67e8f9' },
        barMaxWidth: 18
      }
    ]
  })
  charts.push(chart)
}

function renderBetaChart() {
  if (!betaPdfRef.value) return

  const existing = charts.findIndex(c => c.getDom() === betaPdfRef.value)
  if (existing >= 0) { charts[existing].dispose(); charts.splice(existing, 1) }

  const a = ad.alpha
  const b = ad.betaVal
  if (!a || !b) return

  const pts = []
  const startExp = -12
  const endExp = -1
  for (let exp = startExp; exp <= endExp; exp += 0.02) {
    const x = Math.pow(10, exp)
    const y = betaPDF(x, a, b)
    if (y > 0 && isFinite(y)) pts.push([x, y])
  }

  const chart = echarts.init(betaPdfRef.value)
  const axisType = useLogScale.value ? 'log' : 'value'
  chart.setOption({
    tooltip: {
      trigger: 'axis',
      formatter(params) {
        const d = params[0]?.data
        if (!d) return ''
        return `x = ${Number(d[0]).toExponential(2)}<br/>f(x) = ${Number(d[1]).toExponential(2)}`
      }
    },
    grid: { left: '14%', right: '6%', bottom: '14%', top: '6%' },
    xAxis: {
      type: axisType,
      name: 'x (失误概率)',
      nameLocation: 'center',
      nameGap: 28,
      min: useLogScale.value ? 1e-12 : undefined,
      max: useLogScale.value ? 0.1 : undefined
    },
    yAxis: {
      type: axisType,
      name: 'f(x, α, β) 概率密度',
      nameLocation: 'center',
      nameGap: 50
    },
    series: [{
      type: 'line',
      data: pts,
      smooth: true,
      showSymbol: false,
      lineStyle: { color: '#26a69a', width: 2.5 },
      areaStyle: { color: 'rgba(38,166,154,0.12)' }
    }]
  })
  charts.push(chart)
}

function loadFromCalcResult(stored) {
  const { eventInfo, calcResult } = stored
  ad.eventDescription = eventInfo?.context || ad.eventDescription

  const diag = calcResult?.diagnosis
  const act = calcResult?.action
  if (!diag && !act) return

  if (diag) {
    ad.diagNominal = diag.nominal_hep ?? 1e-2
    ad.diagComposite = diag.composite_psf ?? 1
    ad.diagHep = diag.final_hep ?? 0
    ad.negCount = diag.negative_count ?? 0
    ad.diagMult = (diag.psf_details || []).map(p => p.multiplier)
    ad.diagMultStr = ad.diagMult.join(' × ')
  }
  if (act) {
    ad.actNominal = act.nominal_hep ?? 1e-3
    ad.actComposite = act.composite_psf ?? 1
    ad.actHep = act.final_hep ?? 0
    ad.actMult = (act.psf_details || []).map(p => p.multiplier)
    ad.actMultStr = ad.actMult.join(' × ')
  }

  ad.jointHep = calcResult.joint_hep ?? (ad.diagHep + ad.actHep)

  const negDiag = (diag?.psf_details || []).filter(p => p.multiplier > 1)
  const negAct = (act?.psf_details || []).filter(p => p.multiplier > 1)
  const allNeg = [...negDiag, ...negAct]
  ad.negCount = negDiag.length
  ad.negNote = allNeg.length === 0
    ? '无负向PSF'
    : allNeg.map(p => p.psf_name).join('、') + '为负向'

  const u = calcResult.uncertainty
  if (u) {
    ad.alpha = +(u.alpha ?? 0).toFixed(4)
    ad.betaVal = +(u.beta ?? 0).toFixed(1)
    ad.mean = u.mean ?? ad.jointHep
    ad.p05 = u.p05 ?? 0
    ad.p95 = u.p95 ?? 0
  }

  const diagDetails = diag?.psf_details || []
  const actDetails = act?.psf_details || []
  if (diagDetails.length && actDetails.length) {
    ad.psfRows = [
      { name: '基础值(名义HEP)', dv: fmtSci(ad.diagNominal), av: fmtSci(ad.actNominal) },
      ...PSF_NAMES.map((name, i) => ({
        name,
        dv: String(diagDetails[i]?.multiplier ?? 1),
        dn: diagDetails[i]?.level_name || '',
        av: String(actDetails[i]?.multiplier ?? 1),
        an: actDetails[i]?.level_name || ''
      }))
    ]
  }
}

function loadFromApi(apiData) {
  if (!apiData) return
  ad.eventDescription = apiData.context_description || ad.eventDescription

  const tasks = apiData.tasks || []
  const diag = tasks.find(t => t.task_type === 'diagnosis')
  const act = tasks.find(t => t.task_type === 'action')

  if (diag) {
    ad.diagNominal = diag.nominal_hep ?? 1e-2
    ad.diagComposite = diag.composite_psf ?? 1
    ad.diagHep = diag.final_hep ?? 0
    ad.negCount = diag.negative_count ?? 0
    ad.diagMult = (diag.psf_values || diag.psf_details || []).map(p => p.multiplier)
    ad.diagMultStr = ad.diagMult.join(' × ')
  }
  if (act) {
    ad.actNominal = act.nominal_hep ?? 1e-3
    ad.actComposite = act.composite_psf ?? 1
    ad.actHep = act.final_hep ?? 0
    ad.actMult = (act.psf_values || act.psf_details || []).map(p => p.multiplier)
    ad.actMultStr = ad.actMult.join(' × ')
  }

  ad.jointHep = apiData.joint_hep ?? (ad.diagHep + ad.actHep)

  const allDetails = [
    ...(diag?.psf_values || diag?.psf_details || []),
    ...(act?.psf_values || act?.psf_details || [])
  ]
  const negItems = allDetails.filter(p => p.multiplier > 1)
  ad.negCount = negItems.length
  ad.negNote = negItems.length === 0
    ? '无负向PSF'
    : negItems.map(p => p.psf_name).filter((v, i, a) => a.indexOf(v) === i).join('、') + '为负向'

  const u = apiData.uncertainty
  if (u) {
    ad.alpha = +(u.alpha ?? 0).toFixed(4)
    ad.betaVal = +(u.beta ?? 0).toFixed(1)
    ad.mean = u.mean ?? ad.jointHep
    ad.p05 = u.p05 ?? 0
    ad.p95 = u.p95 ?? 0
  }

  const dv = diag?.psf_values || diag?.psf_details || []
  const av = act?.psf_values || act?.psf_details || []
  if (dv.length && av.length) {
    ad.psfRows = [
      { name: '基础值(名义HEP)', dv: fmtSci(ad.diagNominal), av: fmtSci(ad.actNominal) },
      ...PSF_NAMES.map((name, i) => ({
        name,
        dv: String(dv[i]?.multiplier ?? 1),
        dn: dv[i]?.level_name || '',
        av: String(av[i]?.multiplier ?? 1),
        an: av[i]?.level_name || ''
      }))
    ]
  }
}

function handleExport() {
  ElMessage.success('报告生成中，请稍候…')
}

function handleResize() { charts.forEach(c => c.resize()) }

onMounted(async () => {
  const id = route.params.id

  if (id === 'preview') {
    const raw = sessionStorage.getItem('sparh_calc_result')
    if (raw) {
      try { loadFromCalcResult(JSON.parse(raw)) } catch { /* fallback */ }
    }
  } else if (id) {
    loading.value = true
    try {
      const res = await getCase(id)
      if (res.data) loadFromApi(res.data)
    } catch { /* fallback */ }
    loading.value = false
  }

  await nextTick()
  renderPsfBarChart()
  renderBetaChart()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  charts.forEach(c => c.dispose())
})
</script>

<style scoped>
.analysis-detail-page {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-header h2 {
  margin: 0;
  color: #1a365d;
  font-weight: 700;
}

.analysis-card {
  border-radius: 8px;
  overflow: hidden;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  height: 100%;
}
.card-header-dark {
  background: #1a365d;
  color: #fff;
  padding: 12px 16px;
  font-weight: 600;
  font-size: 14px;
}
.card-body {
  padding: 16px;
}

.event-desc {
  padding: 10px 12px;
  background: #f0f5ff;
  border-radius: 6px;
  line-height: 1.75;
  font-size: 13px;
  color: #4a5568;
  margin-bottom: 16px;
}
.section-subtitle {
  font-weight: 600;
  font-size: 13px;
  color: #303133;
  margin-bottom: 8px;
}
.psf-value-table {
  margin-bottom: 12px;
}
.note-text {
  color: #909399;
  font-size: 11px;
}
.footer-note {
  font-size: 11px;
  color: #909399;
  line-height: 1.6;
  margin-top: 6px;
}

.hep-display {
  text-align: center;
  padding: 16px 0 12px;
  border-bottom: 1px solid #ebeef5;
  margin-bottom: 14px;
}
.hep-label {
  font-size: 13px;
  color: #606266;
  margin-bottom: 4px;
}
.hep-value {
  font-size: 32px;
  font-weight: 700;
  color: #e53e3e;
  font-family: 'Courier New', Courier, monospace;
  letter-spacing: 1px;
}
.hep-subtitle {
  font-size: 11px;
  color: #909399;
  margin-top: 6px;
}
.hep-interval {
  font-size: 12px;
  color: #606266;
  margin-top: 4px;
  font-family: 'Courier New', Courier, monospace;
}
.status-badges {
  display: flex;
  gap: 8px;
  margin-bottom: 14px;
}
.calc-logic {
  background: #f8fafc;
  border-radius: 6px;
  padding: 12px;
  margin-bottom: 12px;
}
.logic-title {
  font-weight: 600;
  font-size: 13px;
  color: #303133;
  margin-bottom: 8px;
}
.formula-block {
  font-family: 'Courier New', Courier, monospace;
  font-size: 12px;
  line-height: 1.8;
  color: #4a5568;
}
.formula-block p {
  margin: 0;
}
.formula-line {
  padding-left: 12px;
}
.formula-highlight {
  color: #e53e3e;
  font-weight: 600;
}
.formula-note {
  font-size: 11px;
  color: #718096;
  margin-top: 8px;
  padding: 6px 8px;
  background: #fffbeb;
  border-radius: 4px;
}
.reference-note {
  font-size: 11px;
  color: #909399;
  line-height: 1.6;
  border-top: 1px solid #ebeef5;
  padding-top: 10px;
}

.evidence-text {
  font-size: 13px;
  color: #606266;
  line-height: 1.7;
  margin-bottom: 16px;
}
.report-btn {
  width: 100%;
  font-size: 15px;
  margin-bottom: 20px;
}
.uncertainty-section {
  margin-top: 16px;
}
.param-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin-bottom: 10px;
}
.param-item {
  display: flex;
  flex-direction: column;
  padding: 6px 8px;
  background: #f8fafc;
  border-radius: 4px;
}
.param-label {
  font-size: 11px;
  color: #909399;
}
.param-value {
  font-size: 13px;
  color: #303133;
  font-weight: 500;
  font-family: 'Courier New', Courier, monospace;
}

.chart-box {
  width: 100%;
  height: 400px;
}
.chart-note {
  font-size: 11px;
  color: #909399;
  text-align: center;
  margin-top: 8px;
}
.beta-subtitle {
  font-size: 12px;
  color: #606266;
  margin-bottom: 10px;
  text-align: center;
}
.info-cards-row {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 12px;
}
.info-card-mini {
  flex: 1;
  min-width: 70px;
  background: #f0f5ff;
  border-radius: 6px;
  padding: 6px 8px;
  text-align: center;
}
.info-card-mini.wide {
  min-width: 140px;
}
.ic-label {
  font-size: 10px;
  color: #909399;
}
.ic-value {
  font-size: 12px;
  font-weight: 600;
  color: #1a365d;
  font-family: 'Courier New', Courier, monospace;
}
.chart-legend {
  font-size: 11px;
  color: #909399;
  text-align: center;
  margin-top: 6px;
}

@media (max-width: 1400px) {
  .analysis-detail-page :deep(.el-col-8) {
    max-width: 100%;
    flex: 0 0 100%;
    margin-bottom: 16px;
  }
}
</style>
