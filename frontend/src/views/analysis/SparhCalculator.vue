<template>
  <div class="sparh-calc">
    <div class="page-header">
      <h2><el-icon><SetUp /></el-icon> SPAR-H 人因可靠性计算器</h2>
    </div>

    <el-steps :active="currentStep" finish-status="success" align-center class="calc-steps">
      <el-step title="工况与任务" />
      <el-step title="PSF赋值" />
      <el-step title="相关性分析" />
      <el-step title="计算结果" />
      <el-step title="可视化" />
    </el-steps>

    <!-- Step 1: 工况与任务类型 -->
    <el-card v-show="currentStep === 0" shadow="never" class="step-card">
      <template #header><span class="card-title">选择工况和任务类型</span></template>
      <el-form label-width="120px">
        <el-form-item label="电厂工况">
          <el-radio-group v-model="plantMode" size="large">
            <el-radio-button value="full_power">
              <el-icon><Sunny /></el-icon> 满功率运行
            </el-radio-button>
            <el-radio-button value="low_power">
              <el-icon><Moon /></el-icon> 低功率/停堆
            </el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="任务类型">
          <el-checkbox-group v-model="taskTypes" size="large">
            <el-checkbox-button value="diagnosis">
              <el-icon><View /></el-icon> 诊断任务 (Diagnosis)
            </el-checkbox-button>
            <el-checkbox-button value="action">
              <el-icon><Operation /></el-icon> 动作任务 (Action)
            </el-checkbox-button>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item>
          <div class="mode-info">
            <el-alert
              :title="plantMode === 'full_power' ? '满功率运行模式：名义HEP诊断=1E-2，动作=1E-3' : '低功率/停堆模式：名义HEP诊断=1E-2，动作=1E-3'"
              type="info"
              show-icon
              :closable="false"
            />
          </div>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Step 2: PSF赋值 -->
    <el-card v-show="currentStep === 1" shadow="never" class="step-card">
      <template #header><span class="card-title">PSF绩效因子赋值</span></template>

      <el-tabs v-model="psfActiveTab" type="card" v-if="taskTypes.length">
        <el-tab-pane
          v-for="tt in taskTypes"
          :key="tt"
          :label="tt === 'diagnosis' ? '诊断任务 PSF' : '动作任务 PSF'"
          :name="tt"
        >
          <div class="psf-grid">
            <div v-for="psf in psfList" :key="psf.code" class="psf-item">
              <el-card shadow="hover" class="psf-card">
                <div class="psf-header">
                  <span class="psf-name">{{ psf.name }}</span>
                  <el-tag v-if="getPsfMultiplier(tt, psf.code) > 1" type="danger" size="small">
                    ×{{ getPsfMultiplier(tt, psf.code) }}
                  </el-tag>
                  <el-tag v-else-if="getPsfMultiplier(tt, psf.code) < 1" type="success" size="small">
                    ×{{ getPsfMultiplier(tt, psf.code) }}
                  </el-tag>
                  <el-tag v-else size="small">×1</el-tag>
                </div>
                <el-select
                  v-model="psfSelections[tt][psf.code]"
                  placeholder="请选择等级"
                  style="width: 100%"
                  @change="onPsfChange(tt, psf.code)"
                >
                  <el-option
                    v-for="opt in getPsfOptions(tt, psf.code)"
                    :key="opt.level_code"
                    :label="`${opt.level_name} (×${opt.multiplier})`"
                    :value="opt.level_code"
                  />
                </el-select>
                <div class="psf-desc" v-if="getPsfDesc(tt, psf.code)">
                  {{ getPsfDesc(tt, psf.code) }}
                </div>
              </el-card>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
      <el-empty v-else description="请先在步骤1中选择任务类型" />
    </el-card>

    <!-- Step 3: 相关性分析 -->
    <el-card v-show="currentStep === 2" shadow="never" class="step-card">
      <template #header><span class="card-title">相关性分析</span></template>

      <div v-if="taskTypes.length === 2">
        <el-alert title="您选择了诊断和动作两个任务，可以进行相关性评估" type="info" show-icon :closable="false" style="margin-bottom: 20px" />
        <el-form label-width="160px">
          <el-form-item label="同一班组操作">
            <el-switch v-model="depFlags.same_crew" active-text="是" inactive-text="否" />
          </el-form-item>
          <el-form-item label="时间上接近">
            <el-switch v-model="depFlags.close_in_time" active-text="是" inactive-text="否" />
          </el-form-item>
          <el-form-item label="同一地点">
            <el-switch v-model="depFlags.same_location" active-text="是" inactive-text="否" />
          </el-form-item>
          <el-form-item label="相同提示/线索">
            <el-switch v-model="depFlags.same_cues" active-text="是" inactive-text="否" />
          </el-form-item>
          <el-form-item label="相关性等级">
            <el-select v-model="depLevel" style="width: 280px">
              <el-option label="完全相关 (CD) - 修正系数=1.0" value="CD" />
              <el-option label="高度相关 (HD) - 修正系数=(1+HEP)/2" value="HD" />
              <el-option label="中度相关 (MD) - 修正系数=(1+6×HEP)/7" value="MD" />
              <el-option label="低度相关 (LD) - 修正系数=(1+19×HEP)/20" value="LD" />
              <el-option label="零相关 (ZD) - 无修正" value="ZD" />
            </el-select>
          </el-form-item>
        </el-form>
      </div>
      <div v-else>
        <el-alert title="相关性分析需同时选择诊断和动作两个任务类型" type="warning" show-icon :closable="false" />
      </div>
    </el-card>

    <!-- Step 4: 计算结果 -->
    <el-card v-show="currentStep === 3" shadow="never" class="step-card">
      <template #header><span class="card-title">计算结果</span></template>

      <div v-if="calcResult" class="result-area">
        <div v-for="(taskRes, idx) in calcResult.tasks" :key="idx" class="task-result-block">
          <h4 class="task-result-title">
            {{ taskRes.task_type === 'diagnosis' ? '诊断任务' : '动作任务' }} 计算过程
          </h4>

          <!-- 计算过程 -->
          <el-card shadow="never" class="process-card">
            <div class="calc-step">
              <span class="step-label">① 名义HEP:</span>
              <span class="step-value">{{ fmtSci(taskRes.nominal_hep) }}</span>
            </div>
            <el-divider />
            <div class="calc-step">
              <span class="step-label">② PSF乘数表:</span>
            </div>
            <el-table :data="taskRes.psf_details" stripe border size="small" style="margin: 8px 0">
              <el-table-column prop="psf_name" label="PSF因子" width="140" />
              <el-table-column prop="level_name" label="选定等级" width="140" />
              <el-table-column prop="multiplier" label="乘数" width="100" align="center">
                <template #default="{ row }">
                  <span :style="{ color: row.multiplier > 1 ? '#F56C6C' : row.multiplier < 1 ? '#67C23A' : '#303133', fontWeight: 600 }">
                    {{ row.multiplier }}
                  </span>
                </template>
              </el-table-column>
              <el-table-column prop="is_negative" label="负向" width="80" align="center">
                <template #default="{ row }">
                  <el-tag v-if="row.is_negative" type="danger" size="small">是</el-tag>
                </template>
              </el-table-column>
            </el-table>
            <el-divider />
            <div class="calc-step">
              <span class="step-label">③ 复合PSF:</span>
              <span class="step-value">{{ fmtNum(taskRes.composite_psf) }}</span>
              <span class="step-formula">(各PSF乘数之积)</span>
            </div>
            <div class="calc-step">
              <span class="step-label">④ 原始HEP:</span>
              <span class="step-value">{{ fmtSci(taskRes.raw_hep) }}</span>
              <span class="step-formula">= 名义HEP × 复合PSF</span>
            </div>
            <div class="calc-step">
              <span class="step-label">⑤ 调整后HEP:</span>
              <span class="step-value">{{ fmtSci(taskRes.adjusted_hep) }}</span>
              <span class="step-formula" v-if="taskRes.negative_count >= 3">
                (≥3个负向因子: NHEP×PSF/(NHEP×(PSF-1)+1))
              </span>
              <span class="step-formula" v-else>= 原始HEP（负向因子＜3个）</span>
            </div>
            <div class="calc-step">
              <span class="step-label">⑥ 最终HEP:</span>
              <span class="step-value final-hep">{{ fmtSci(taskRes.final_hep) }}</span>
              <span class="step-formula">(上限截断为1.0)</span>
            </div>
          </el-card>

          <!-- 不确定性 -->
          <div v-if="taskRes.uncertainty" class="uncertainty-block">
            <h5>不确定性分析结果</h5>
            <el-descriptions :column="3" border size="small">
              <el-descriptions-item label="分布">{{ taskRes.uncertainty.dist_type || 'Beta' }}</el-descriptions-item>
              <el-descriptions-item label="α">{{ fmtNum(taskRes.uncertainty.alpha_param) }}</el-descriptions-item>
              <el-descriptions-item label="β">{{ fmtNum(taskRes.uncertainty.beta_param) }}</el-descriptions-item>
              <el-descriptions-item label="误差因子">{{ fmtNum(taskRes.uncertainty.error_factor) }}</el-descriptions-item>
              <el-descriptions-item label="均值">{{ fmtSci(taskRes.uncertainty.mean_hep) }}</el-descriptions-item>
              <el-descriptions-item label="中位数">{{ fmtSci(taskRes.uncertainty.median_hep) }}</el-descriptions-item>
              <el-descriptions-item label="P5 (5%)">{{ fmtSci(taskRes.uncertainty.p05) }}</el-descriptions-item>
              <el-descriptions-item label="P50 (50%)">{{ fmtSci(taskRes.uncertainty.p50) }}</el-descriptions-item>
              <el-descriptions-item label="P95 (95%)">{{ fmtSci(taskRes.uncertainty.p95) }}</el-descriptions-item>
            </el-descriptions>
          </div>
        </div>

        <!-- 联合HEP -->
        <div v-if="calcResult.joint_hep != null" class="joint-block">
          <el-divider content-position="center">联合HEP</el-divider>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="联合HEP (诊断×动作)">
              <span class="final-hep" style="font-size: 18px">{{ fmtSci(calcResult.joint_hep) }}</span>
            </el-descriptions-item>
            <el-descriptions-item v-if="calcResult.dep_corrected_hep != null" label="相关性修正后HEP">
              <span class="final-hep" style="font-size: 18px">{{ fmtSci(calcResult.dep_corrected_hep) }}</span>
            </el-descriptions-item>
          </el-descriptions>
        </div>
      </div>
      <el-empty v-else description="请点击下方【开始计算】按钮" />
    </el-card>

    <!-- Step 5: 可视化 -->
    <el-card v-show="currentStep === 4" shadow="never" class="step-card">
      <template #header><span class="card-title">可视化分析</span></template>
      <el-row :gutter="16" v-if="calcResult">
        <el-col :span="12">
          <div class="chart-label">PSF乘数柱状图</div>
          <div ref="visPsfChartRef" class="chart-box"></div>
        </el-col>
        <el-col :span="12">
          <div class="chart-label">Beta分布概率密度函数曲线</div>
          <div ref="visBetaChartRef" class="chart-box"></div>
        </el-col>
      </el-row>
      <el-empty v-else description="请先完成计算" />
    </el-card>

    <!-- 底部操作按钮 -->
    <div class="step-actions">
      <el-button @click="prevStep" :disabled="currentStep === 0" size="large">
        <el-icon><ArrowLeft /></el-icon> 上一步
      </el-button>
      <el-button
        v-if="currentStep < 3"
        type="primary"
        @click="nextStep"
        size="large"
        :disabled="currentStep === 0 && taskTypes.length === 0"
      >
        下一步 <el-icon><ArrowRight /></el-icon>
      </el-button>
      <el-button
        v-if="currentStep === 3 && !calcResult"
        type="success"
        @click="doCalculate"
        :loading="calculating"
        size="large"
      >
        <el-icon><VideoPlay /></el-icon> 开始计算
      </el-button>
      <el-button
        v-if="currentStep === 3 && calcResult"
        type="primary"
        @click="nextStep"
        size="large"
      >
        查看可视化 <el-icon><ArrowRight /></el-icon>
      </el-button>
      <el-button
        v-if="currentStep === 4 && calcResult"
        type="warning"
        @click="saveAsCase"
        :loading="saving"
        size="large"
      >
        <el-icon><FolderAdd /></el-icon> 保存为分析案例
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch, nextTick, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { sparhCalc, sparhSaveCase } from '@/api/analysis'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as echarts from 'echarts'

const router = useRouter()
const currentStep = ref(0)
const plantMode = ref('full_power')
const taskTypes = ref(['diagnosis'])
const psfActiveTab = ref('diagnosis')

const psfList = [
  { code: 'TIME', name: '可用时间' },
  { code: 'STRESS', name: '压力' },
  { code: 'COMPLEXITY', name: '复杂度' },
  { code: 'TRAINING', name: '经验/培训' },
  { code: 'PROCEDURE', name: '规程' },
  { code: 'ERGONOMICS', name: '工效学/人机界面' },
  { code: 'FITNESS', name: '职责适宜' },
  { code: 'PROCESS', name: '工序' },
]

const psfDict = reactive({})

const psfSelections = reactive({
  diagnosis: { TIME: '', STRESS: '', COMPLEXITY: '', TRAINING: '', PROCEDURE: '', ERGONOMICS: '', FITNESS: '', PROCESS: '' },
  action: { TIME: '', STRESS: '', COMPLEXITY: '', TRAINING: '', PROCEDURE: '', ERGONOMICS: '', FITNESS: '', PROCESS: '' },
})

const depFlags = reactive({ same_crew: false, close_in_time: false, same_location: false, same_cues: false })
const depLevel = ref('ZD')

const calculating = ref(false)
const saving = ref(false)
const calcResult = ref(null)

const visPsfChartRef = ref(null)
const visBetaChartRef = ref(null)
let visCharts = []

function buildPsfDict() {
  const modes = [plantMode.value]
  const types = ['diagnosis', 'action']
  for (const mode of modes) {
    for (const tt of types) {
      const key = `${mode}_${tt}`
      if (!psfDict[key]) {
        psfDict[key] = buildLocalPsfDict(mode, tt)
      }
    }
  }
}

function buildLocalPsfDict(mode, taskType) {
  const dict = {}
  const m = mode === 'full_power' ? 'full_power' : 'low_power'
  const base = {
    TIME: {
      diagnosis: [
        { level_code: 'TIME_INSUFF', level_name: '时间不足够', multiplier: 1.0, is_negative: 1, definition_text: 'P(failure)=1.0' },
        { level_code: 'TIME_BARELY', level_name: '时间刚好够(<20min)', multiplier: 10.0, is_negative: 1, definition_text: '可用时间少于20分钟' },
        { level_code: 'TIME_NOMINAL', level_name: '通常时间(30min)', multiplier: 1.0, is_negative: 0, definition_text: '通常时间约30分钟' },
        { level_code: 'TIME_EXTRA', level_name: '充足的时间(>60min)', multiplier: 0.1, is_negative: 0, definition_text: '充足的时间大于60分钟' },
        { level_code: 'TIME_VAST', level_name: '很多时间(>24h)', multiplier: 0.01, is_negative: 0, definition_text: '大量可用时间超过24小时' },
      ],
      action: [
        { level_code: 'TIME_INSUFF', level_name: '时间不足够', multiplier: 1.0, is_negative: 1, definition_text: 'P(failure)=1.0' },
        { level_code: 'TIME_BARELY', level_name: '可用时间=所需时间', multiplier: 10.0, is_negative: 1, definition_text: '可用时间刚好等于所需时间' },
        { level_code: 'TIME_NOMINAL', level_name: '通常时间', multiplier: 1.0, is_negative: 0, definition_text: '通常时间' },
        { level_code: 'TIME_EXTRA', level_name: '充足的时间(≥5倍所需)', multiplier: 0.1, is_negative: 0, definition_text: '充足的时间' },
        { level_code: 'TIME_VAST', level_name: '很多时间(≥50倍所需)', multiplier: 0.01, is_negative: 0, definition_text: '大量可用时间' },
      ],
    },
    STRESS: {
      diagnosis: [
        { level_code: 'STRESS_HIGH2', level_name: '很高', multiplier: 5.0, is_negative: 1, definition_text: '很高的压力水平' },
        { level_code: 'STRESS_HIGH', level_name: '高', multiplier: 2.0, is_negative: 1, definition_text: '高压力水平' },
        { level_code: 'STRESS_NOMINAL', level_name: '正常', multiplier: 1.0, is_negative: 0, definition_text: '正常压力水平' },
      ],
      action: [
        { level_code: 'STRESS_HIGH2', level_name: '很高', multiplier: 5.0, is_negative: 1, definition_text: '很高的压力水平' },
        { level_code: 'STRESS_HIGH', level_name: '高', multiplier: 2.0, is_negative: 1, definition_text: '高压力水平' },
        { level_code: 'STRESS_NOMINAL', level_name: '正常', multiplier: 1.0, is_negative: 0, definition_text: '正常压力水平' },
      ],
    },
    COMPLEXITY: {
      diagnosis: [
        { level_code: 'CMPLX_HIGH', level_name: '高度复杂', multiplier: 5.0, is_negative: 1, definition_text: '高度复杂的任务' },
        { level_code: 'CMPLX_MED', level_name: '中等复杂', multiplier: 2.0, is_negative: 1, definition_text: '中等复杂度' },
        { level_code: 'CMPLX_NOMINAL', level_name: '正常', multiplier: 1.0, is_negative: 0, definition_text: '正常复杂度' },
        { level_code: 'CMPLX_EASY', level_name: '很容易诊断', multiplier: 0.1, is_negative: 0, definition_text: '非常容易诊断' },
      ],
      action: [
        { level_code: 'CMPLX_HIGH', level_name: '高度复杂', multiplier: 5.0, is_negative: 1, definition_text: '高度复杂的任务' },
        { level_code: 'CMPLX_MED', level_name: '中等复杂', multiplier: 2.0, is_negative: 1, definition_text: '中等复杂度' },
        { level_code: 'CMPLX_NOMINAL', level_name: '正常', multiplier: 1.0, is_negative: 0, definition_text: '正常复杂度' },
      ],
    },
    TRAINING: {
      diagnosis: [
        { level_code: 'TRAIN_LOW', level_name: '低', multiplier: 10.0, is_negative: 1, definition_text: '经验/培训不足' },
        { level_code: 'TRAIN_NOMINAL', level_name: '正常', multiplier: 1.0, is_negative: 0, definition_text: '正常培训水平' },
        { level_code: 'TRAIN_HIGH', level_name: '高', multiplier: 0.5, is_negative: 0, definition_text: '高水平培训' },
      ],
      action: [
        { level_code: 'TRAIN_LOW', level_name: '低', multiplier: 3.0, is_negative: 1, definition_text: '经验/培训不足' },
        { level_code: 'TRAIN_NOMINAL', level_name: '正常', multiplier: 1.0, is_negative: 0, definition_text: '正常培训水平' },
        { level_code: 'TRAIN_HIGH', level_name: '高', multiplier: 0.5, is_negative: 0, definition_text: '高水平培训' },
      ],
    },
    PROCEDURE: {
      diagnosis: [
        { level_code: 'PROC_NONE', level_name: '无', multiplier: 50.0, is_negative: 1, definition_text: '没有可用规程' },
        { level_code: 'PROC_INCOMPLETE', level_name: '有，但不完整', multiplier: 20.0, is_negative: 1, definition_text: '规程不完整' },
        { level_code: 'PROC_POOR', level_name: '有，但较差', multiplier: 5.0, is_negative: 1, definition_text: '规程质量较差' },
        { level_code: 'PROC_NOMINAL', level_name: '一般', multiplier: 1.0, is_negative: 0, definition_text: '一般规程' },
        { level_code: 'PROC_SYMPTOM', level_name: '征兆导向规程', multiplier: 0.5, is_negative: 0, definition_text: '征兆导向规程' },
      ],
      action: [
        { level_code: 'PROC_NONE', level_name: '无', multiplier: 50.0, is_negative: 1, definition_text: '没有可用规程' },
        { level_code: 'PROC_INCOMPLETE', level_name: '有，但不完整', multiplier: 20.0, is_negative: 1, definition_text: '规程不完整' },
        { level_code: 'PROC_POOR', level_name: '有，但较差', multiplier: 5.0, is_negative: 1, definition_text: '规程质量较差' },
        { level_code: 'PROC_NOMINAL', level_name: '一般', multiplier: 1.0, is_negative: 0, definition_text: '一般规程' },
      ],
    },
    ERGONOMICS: {
      diagnosis: [
        { level_code: 'ERGO_MISSING', level_name: '缺失/误导', multiplier: 50.0, is_negative: 1, definition_text: '人机界面信息缺失或误导' },
        { level_code: 'ERGO_POOR', level_name: '差', multiplier: 10.0, is_negative: 1, definition_text: '人机界面质量差' },
        { level_code: 'ERGO_NOMINAL', level_name: '一般', multiplier: 1.0, is_negative: 0, definition_text: '一般人机界面' },
        { level_code: 'ERGO_GOOD', level_name: '好', multiplier: 0.5, is_negative: 0, definition_text: '良好的人机界面' },
      ],
      action: [
        { level_code: 'ERGO_MISSING', level_name: '缺失/误导', multiplier: 50.0, is_negative: 1, definition_text: '人机界面信息缺失或误导' },
        { level_code: 'ERGO_POOR', level_name: '差', multiplier: 10.0, is_negative: 1, definition_text: '人机界面质量差' },
        { level_code: 'ERGO_NOMINAL', level_name: '一般', multiplier: 1.0, is_negative: 0, definition_text: '一般人机界面' },
        { level_code: 'ERGO_GOOD', level_name: '好', multiplier: 0.5, is_negative: 0, definition_text: '良好的人机界面' },
      ],
    },
    FITNESS: {
      diagnosis: [
        { level_code: 'FIT_UNFIT', level_name: '不适宜', multiplier: 1.0, is_negative: 1, definition_text: 'P(failure)=1.0，直接判定失败' },
        { level_code: 'FIT_DEGRADED', level_name: '不太适宜', multiplier: 5.0, is_negative: 1, definition_text: '身体或精神状态不太适宜' },
        { level_code: 'FIT_NOMINAL', level_name: '正常', multiplier: 1.0, is_negative: 0, definition_text: '正常适宜' },
      ],
      action: [
        { level_code: 'FIT_UNFIT', level_name: '不适宜', multiplier: 1.0, is_negative: 1, definition_text: 'P(failure)=1.0' },
        { level_code: 'FIT_DEGRADED', level_name: '不太适宜', multiplier: 5.0, is_negative: 1, definition_text: '身体或精神状态不太适宜' },
        { level_code: 'FIT_NOMINAL', level_name: '正常', multiplier: 1.0, is_negative: 0, definition_text: '正常适宜' },
      ],
    },
    PROCESS: {
      diagnosis: [
        { level_code: 'PROC_POOR', level_name: '差', multiplier: 5.0, is_negative: 1, definition_text: '工序组织差' },
        { level_code: 'PROC_NOMINAL', level_name: '一般', multiplier: 1.0, is_negative: 0, definition_text: '一般工序' },
        { level_code: 'PROC_GOOD', level_name: '好', multiplier: 0.8, is_negative: 0, definition_text: '良好的工序' },
      ],
      action: [
        { level_code: 'PROC_POOR', level_name: '差', multiplier: 5.0, is_negative: 1, definition_text: '工序组织差' },
        { level_code: 'PROC_NOMINAL', level_name: '一般', multiplier: 1.0, is_negative: 0, definition_text: '一般工序' },
        { level_code: 'PROC_GOOD', level_name: '好', multiplier: 0.5, is_negative: 0, definition_text: '良好的工序' },
      ],
    },
  }

  for (const code of Object.keys(base)) {
    dict[code] = base[code][taskType] || base[code].diagnosis
  }
  return dict
}

buildPsfDict()

function getPsfOptions(taskType, psfCode) {
  const key = `${plantMode.value}_${taskType}`
  return psfDict[key]?.[psfCode] || []
}

function getSelectedOption(taskType, psfCode) {
  const val = psfSelections[taskType][psfCode]
  if (!val) return null
  return getPsfOptions(taskType, psfCode).find(o => o.level_code === val) || null
}

function getPsfMultiplier(taskType, psfCode) {
  const opt = getSelectedOption(taskType, psfCode)
  return opt ? opt.multiplier : 1
}

function getPsfDesc(taskType, psfCode) {
  const opt = getSelectedOption(taskType, psfCode)
  return opt?.definition_text || ''
}

function onPsfChange() { /* triggers reactivity */ }

watch([plantMode], () => {
  buildPsfDict()
})

watch(taskTypes, (val) => {
  if (val.length && !val.includes(psfActiveTab.value)) {
    psfActiveTab.value = val[0]
  }
})

function prevStep() { if (currentStep.value > 0) currentStep.value-- }
function nextStep() {
  if (currentStep.value < 4) {
    currentStep.value++
    if (currentStep.value === 4 && calcResult.value) {
      nextTick(renderVisCharts)
    }
  }
}

function fmtSci(v) { return v != null ? Number(v).toExponential(3) : '-' }
function fmtNum(v) { return v != null ? Number(v).toFixed(4) : '-' }

function localCalculate() {
  const results = { tasks: [], joint_hep: null, dep_corrected_hep: null }

  for (const tt of taskTypes.value) {
    const nominalHep = tt === 'diagnosis' ? 0.01 : 0.001
    const psfDetails = []
    let compositePsf = 1
    let negativeCount = 0
    let hasInsuff = false

    for (const psf of psfList) {
      const opt = getSelectedOption(tt, psf.code)
      const multiplier = opt ? opt.multiplier : 1
      const isNeg = opt ? opt.is_negative : 0
      psfDetails.push({
        psf_code: psf.code,
        psf_name: psf.name,
        level_code: opt?.level_code || '',
        level_name: opt?.level_name || '正常',
        multiplier,
        is_negative: isNeg,
      })

      if (psf.code === 'TIME' && opt?.level_code === 'TIME_INSUFF') hasInsuff = true
      if (psf.code === 'FITNESS' && opt?.level_code === 'FIT_UNFIT') hasInsuff = true

      compositePsf *= multiplier
      if (isNeg) negativeCount++
    }

    let rawHep, adjustedHep, finalHep

    if (hasInsuff) {
      rawHep = 1.0
      adjustedHep = 1.0
      finalHep = 1.0
    } else {
      rawHep = nominalHep * compositePsf
      if (negativeCount >= 3) {
        adjustedHep = (nominalHep * compositePsf) / (nominalHep * (compositePsf - 1) + 1)
      } else {
        adjustedHep = rawHep
      }
      finalHep = Math.min(adjustedHep, 1.0)
    }

    const hep = finalHep
    const ef = 5
    const mean = hep
    const median = mean / Math.sqrt(ef)
    const p05Bound = mean / (ef * ef)
    const p95Bound = Math.min(mean * ef, 1.0)
    const alphaP = Math.max(0.1, mean * ((mean * (1 - mean)) / (median * 0.3 * median * 0.3) - 1))
    const betaP = Math.max(0.1, alphaP * (1 - mean) / mean)

    results.tasks.push({
      task_type: tt,
      nominal_hep: nominalHep,
      psf_details: psfDetails,
      composite_psf: compositePsf,
      raw_hep: rawHep,
      adjusted_hep: adjustedHep,
      negative_count: negativeCount,
      final_hep: finalHep,
      uncertainty: {
        dist_type: 'Beta',
        alpha_param: alphaP,
        beta_param: betaP,
        error_factor: ef,
        mean_hep: mean,
        median_hep: median,
        p05: p05Bound,
        p50: median,
        p95: p95Bound,
      },
    })
  }

  if (results.tasks.length === 2) {
    const d = results.tasks.find(t => t.task_type === 'diagnosis')
    const a = results.tasks.find(t => t.task_type === 'action')
    results.joint_hep = (d?.final_hep || 0) * (a?.final_hep || 0)

    if (depLevel.value !== 'ZD' && a) {
      const hepAction = a.final_hep
      let corrected
      switch (depLevel.value) {
        case 'CD': corrected = 1.0; break
        case 'HD': corrected = (1 + hepAction) / 2; break
        case 'MD': corrected = (1 + 6 * hepAction) / 7; break
        case 'LD': corrected = (1 + 19 * hepAction) / 20; break
        default: corrected = hepAction
      }
      results.dep_corrected_hep = (d?.final_hep || 0) * corrected
    }
  }

  return results
}

async function doCalculate() {
  if (taskTypes.value.length === 0) {
    ElMessage.warning('请至少选择一种任务类型')
    return
  }

  calculating.value = true
  try {
    const payload = {
      plant_mode: plantMode.value,
      tasks: taskTypes.value.map(tt => ({
        task_type: tt,
        psf_values: psfList.map(psf => {
          const opt = getSelectedOption(tt, psf.code)
          return { psf_code: psf.code, level_code: opt?.level_code || `${psf.code}_NOMINAL` }
        }),
      })),
    }
    if (taskTypes.value.length === 2) {
      payload.dependency = { ...depFlags, level: depLevel.value }
    }

    let res
    try {
      res = await sparhCalc(payload)
      calcResult.value = res.data || res
    } catch {
      calcResult.value = localCalculate()
    }

    ElMessage.success('计算完成')
  } catch {
    calcResult.value = localCalculate()
    ElMessage.success('本地计算完成')
  } finally {
    calculating.value = false
  }
}

function betaPdf(x, a, b) {
  if (x <= 0 || x >= 1) return 0
  const lnB = lnGamma(a) + lnGamma(b) - lnGamma(a + b)
  return Math.exp((a - 1) * Math.log(x) + (b - 1) * Math.log(1 - x) - lnB)
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

function renderVisCharts() {
  visCharts.forEach(c => c.dispose())
  visCharts = []

  if (!calcResult.value?.tasks?.length) return

  const psfNames = psfList.map(p => p.name)
  const series = calcResult.value.tasks.map(task => ({
    name: task.task_type === 'diagnosis' ? '诊断' : '动作',
    type: 'bar',
    data: task.psf_details.map(d => d.multiplier),
    label: { show: true, position: 'top', formatter: '{c}', fontSize: 10 },
  }))

  const psfChart = echarts.init(visPsfChartRef.value)
  psfChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: {},
    xAxis: { type: 'category', data: psfNames, axisLabel: { rotate: 20 } },
    yAxis: { type: 'log', name: '乘数 (对数轴)', min: 0.005 },
    color: ['#409EFF', '#67C23A'],
    series,
    grid: { left: 60, right: 20, top: 50, bottom: 60 },
  })
  visCharts.push(psfChart)

  const firstU = calcResult.value.tasks[0]?.uncertainty
  if (firstU?.alpha_param && firstU?.beta_param) {
    const a = Number(firstU.alpha_param)
    const b = Number(firstU.beta_param)
    const xArr = [], yArr = []
    for (let i = 1; i < 300; i++) {
      const x = i / 300
      xArr.push(x.toFixed(4))
      yArr.push(betaPdf(x, a, b))
    }

    const p05x = firstU.p05 != null ? Number(firstU.p05) : null
    const p50x = firstU.p50 != null ? Number(firstU.p50) : null
    const p95x = firstU.p95 != null ? Number(firstU.p95) : null

    const markLines = []
    if (p05x != null) markLines.push({ name: 'P5', xAxis: p05x.toFixed(4) })
    if (p50x != null) markLines.push({ name: 'P50', xAxis: p50x.toFixed(4) })
    if (p95x != null) markLines.push({ name: 'P95', xAxis: p95x.toFixed(4) })

    const betaChart = echarts.init(visBetaChartRef.value)
    betaChart.setOption({
      tooltip: { trigger: 'axis', formatter: (p) => `HEP: ${p[0]?.name}<br/>密度: ${p[0]?.value?.toFixed(4)}` },
      xAxis: { type: 'category', data: xArr, name: 'HEP', axisLabel: { interval: 59 } },
      yAxis: { type: 'value', name: '概率密度' },
      series: [{
        type: 'line',
        data: yArr,
        smooth: true,
        showSymbol: false,
        lineStyle: { width: 2.5, color: '#E6A23C' },
        areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(230,162,60,0.25)' },
          { offset: 1, color: 'rgba(230,162,60,0.02)' },
        ]) },
        markLine: markLines.length ? {
          symbol: 'none',
          lineStyle: { type: 'dashed', width: 1.5 },
          data: markLines.map(m => ({ ...m, lineStyle: { color: '#F56C6C' }, label: { formatter: m.name, position: 'end' } })),
        } : undefined,
      }],
      grid: { left: 60, right: 30, top: 30, bottom: 40 },
    })
    visCharts.push(betaChart)
  }
}

async function saveAsCase() {
  try {
    const { value: caseName } = await ElMessageBox.prompt('请输入案例名称', '保存分析案例', {
      confirmButtonText: '保存',
      cancelButtonText: '取消',
      inputPlaceholder: '如: 满功率诊断+动作分析',
    })
    if (!caseName) return
    saving.value = true
    const payload = {
      case_name: caseName,
      plant_mode: plantMode.value,
      task_types: taskTypes.value,
      psf_selections: psfSelections,
      dependency: taskTypes.value.length === 2 ? { ...depFlags, level: depLevel.value } : null,
      result: calcResult.value,
    }
    const res = await sparhSaveCase(payload)
    ElMessage.success('案例保存成功')
    router.push(`/analysis/${res.id || res.data?.id || ''}`)
  } catch (e) {
    if (e !== 'cancel') ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

function handleResize() { visCharts.forEach(c => c.resize()) }

window.addEventListener('resize', handleResize)
onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  visCharts.forEach(c => c.dispose())
})
</script>

<style scoped>
.sparh-calc {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.page-header h2 {
  font-size: 22px;
  color: #303133;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.calc-steps {
  margin: 0 40px;
}

.step-card {
  min-height: 300px;
}

.card-title {
  font-weight: 600;
  font-size: 16px;
  color: #303133;
}

.mode-info {
  width: 100%;
  max-width: 500px;
}

/* PSF Grid */
.psf-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

.psf-card {
  height: 100%;
}

.psf-card :deep(.el-card__body) {
  padding: 16px;
}

.psf-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.psf-name {
  font-weight: 600;
  font-size: 14px;
  color: #303133;
}

.psf-desc {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
}

/* Results */
.result-area {
  max-width: 900px;
}

.task-result-block {
  margin-bottom: 32px;
}

.task-result-title {
  font-size: 16px;
  color: #303133;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 2px solid #409EFF;
}

.process-card {
  background: #fafafa;
  margin-bottom: 16px;
}

.calc-step {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 0;
}

.step-label {
  font-weight: 600;
  color: #303133;
  min-width: 120px;
}

.step-value {
  font-size: 16px;
  font-weight: 700;
  color: #409EFF;
  font-family: 'Courier New', monospace;
}

.step-formula {
  font-size: 12px;
  color: #909399;
}

.final-hep {
  color: #F56C6C !important;
}

.uncertainty-block {
  margin-top: 16px;
}

.uncertainty-block h5 {
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
}

.joint-block {
  margin-top: 16px;
}

/* Charts */
.chart-label {
  font-weight: 600;
  font-size: 15px;
  color: #303133;
  margin-bottom: 12px;
  text-align: center;
}

.chart-box {
  height: 380px;
}

/* Actions */
.step-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding: 20px 0;
}
</style>
