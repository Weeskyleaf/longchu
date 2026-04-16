<template>
  <div class="event-detail" v-loading="loading">
    <div class="page-header">
      <el-button @click="$router.back()" text>
        <el-icon><ArrowLeft /></el-icon> 返回列表
      </el-button>
      <h2>{{ eventData.event_title || '事件详情' }}</h2>
    </div>

    <el-tabs v-model="activeTab" type="border-card">
      <!-- 基本信息 -->
      <el-tab-pane label="基本信息" name="basic">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="事件编号">{{ eventData.event_code }}</el-descriptions-item>
          <el-descriptions-item label="事件标题">{{ eventData.event_title }}</el-descriptions-item>
          <el-descriptions-item label="事件类型">
            <el-tag size="small">{{ eventData.event_type }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="主分类">{{ eventData.main_category }}</el-descriptions-item>
          <el-descriptions-item label="子分类">{{ eventData.sub_category }}</el-descriptions-item>
          <el-descriptions-item label="发生时间">{{ formatDate(eventData.occur_time) }}</el-descriptions-item>
          <el-descriptions-item label="电厂名称">{{ eventData.plant_name }}</el-descriptions-item>
          <el-descriptions-item label="机组号">{{ eventData.unit_no }}</el-descriptions-item>
          <el-descriptions-item label="系统名称">{{ eventData.system_name }}</el-descriptions-item>
          <el-descriptions-item label="运行模式">{{ eventData.operation_mode }}</el-descriptions-item>
          <el-descriptions-item label="后果等级">
            <el-tag :type="levelTagMap[eventData.consequence_level] || 'info'" size="small" v-if="eventData.consequence_level">
              {{ eventData.consequence_level }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="事件结果">{{ eventData.event_result }}</el-descriptions-item>
          <el-descriptions-item label="来源类型">{{ eventData.source_type }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ formatDate(eventData.created_at) }}</el-descriptions-item>
        </el-descriptions>
        <el-card shadow="never" style="margin-top: 16px" v-if="eventData.raw_text">
          <template #header><span style="font-weight: 600">原始文本</span></template>
          <div class="raw-text">{{ eventData.raw_text }}</div>
        </el-card>
      </el-tab-pane>

      <!-- 任务信息 -->
      <el-tab-pane label="任务信息" name="tasks">
        <div class="tab-toolbar">
          <el-button type="primary" size="small" @click="taskDialogVisible = true">
            <el-icon><Plus /></el-icon> 添加任务
          </el-button>
        </div>
        <el-table :data="tasks" stripe border>
          <el-table-column prop="task_code" label="任务编号" width="150" />
          <el-table-column prop="task_name" label="任务名称" min-width="180" show-overflow-tooltip />
          <el-table-column prop="task_type" label="任务类型" width="100" align="center">
            <template #default="{ row }">
              <el-tag size="small">{{ row.task_type }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="task_stage" label="任务阶段" width="100" align="center" />
          <el-table-column prop="operation_object" label="操作对象" width="140" />
          <el-table-column prop="available_time" label="可用时间(min)" width="130" align="center" />
          <el-table-column prop="task_desc" label="任务描述" min-width="200" show-overflow-tooltip />
        </el-table>
      </el-tab-pane>

      <!-- 标签信息 -->
      <el-tab-pane label="标签信息" name="tags">
        <div class="tab-toolbar">
          <el-button type="primary" size="small" @click="tagDialogVisible = true">
            <el-icon><Plus /></el-icon> 添加标签
          </el-button>
        </div>
        <el-table :data="tags" stripe border>
          <el-table-column prop="tag_type" label="标签类型" width="120" />
          <el-table-column prop="tag_name" label="标签名称" width="160" />
          <el-table-column prop="tag_value" label="标签值" width="120" />
          <el-table-column prop="label_basis" label="标注依据" min-width="200" show-overflow-tooltip />
          <el-table-column prop="reviewer" label="审核人" width="120" />
          <el-table-column prop="review_status" label="审核状态" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="row.review_status === 'approved' ? 'success' : 'warning'" size="small">
                {{ row.review_status === 'approved' ? '已审核' : '待审核' }}
              </el-tag>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <!-- 影响因素 -->
      <el-tab-pane label="影响因素" name="factors">
        <el-table :data="factors" stripe border>
          <el-table-column prop="factor_category" label="因素类别" width="120" />
          <el-table-column prop="factor_name" label="因素名称" width="160" />
          <el-table-column prop="factor_level" label="因素等级" width="100" align="center" />
          <el-table-column prop="factor_value" label="因素值" width="120" />
          <el-table-column prop="assessment_basis" label="评估依据" min-width="200" show-overflow-tooltip />
          <el-table-column prop="data_source" label="数据来源" width="120" />
          <el-table-column prop="method_mapping" label="方法映射" width="120" />
        </el-table>
      </el-tab-pane>

      <!-- 证据链 -->
      <el-tab-pane label="证据链" name="evidence">
        <el-table :data="evidence" stripe border>
          <el-table-column prop="evidence_type" label="证据类型" width="120" />
          <el-table-column prop="doc_code" label="文档编号" width="150" />
          <el-table-column prop="doc_title" label="文档标题" min-width="200" show-overflow-tooltip />
          <el-table-column prop="source_ref" label="来源引用" width="160" show-overflow-tooltip />
          <el-table-column prop="quote_note" label="引用说明" min-width="200" show-overflow-tooltip />
          <el-table-column prop="operator_name" label="操作人" width="100" />
          <el-table-column prop="operate_time" label="操作时间" width="170">
            <template #default="{ row }">{{ formatDate(row.operate_time) }}</template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <!-- 添加任务对话框 -->
    <el-dialog v-model="taskDialogVisible" title="添加任务" width="600px">
      <el-form :model="taskForm" label-width="100px">
        <el-form-item label="任务编号"><el-input v-model="taskForm.task_code" /></el-form-item>
        <el-form-item label="任务名称"><el-input v-model="taskForm.task_name" /></el-form-item>
        <el-form-item label="任务类型">
          <el-select v-model="taskForm.task_type" style="width: 100%">
            <el-option label="诊断" value="diagnosis" />
            <el-option label="动作" value="action" />
          </el-select>
        </el-form-item>
        <el-form-item label="任务阶段">
          <el-select v-model="taskForm.task_stage" style="width: 100%">
            <el-option label="事故前" value="事故前" />
            <el-option label="事故后" value="事故后" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作对象"><el-input v-model="taskForm.operation_object" /></el-form-item>
        <el-form-item label="可用时间"><el-input-number v-model="taskForm.available_time" :min="0" /></el-form-item>
        <el-form-item label="任务描述"><el-input v-model="taskForm.task_desc" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="taskDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitTask">确定</el-button>
      </template>
    </el-dialog>

    <!-- 添加标签对话框 -->
    <el-dialog v-model="tagDialogVisible" title="添加标签" width="500px">
      <el-form :model="tagForm" label-width="100px">
        <el-form-item label="标签">
          <el-select v-model="tagForm.tag_id" filterable style="width: 100%">
            <el-option
              v-for="t in tagDictList"
              :key="t.id"
              :label="`${t.tag_name} - ${t.tag_value}`"
              :value="t.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="标注依据"><el-input v-model="tagForm.label_basis" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="tagDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitTag">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getEvent, addEventTask, addEventTag, getTagDict } from '@/api/events'
import { ElMessage } from 'element-plus'

const route = useRoute()
const eventId = route.params.id

const loading = ref(false)
const activeTab = ref('basic')
const eventData = ref({})
const tasks = ref([])
const tags = ref([])
const factors = ref([])
const evidence = ref([])
const tagDictList = ref([])

const taskDialogVisible = ref(false)
const tagDialogVisible = ref(false)
const taskForm = ref({ task_code: '', task_name: '', task_type: 'diagnosis', task_stage: '事故前', operation_object: '', available_time: null, task_desc: '' })
const tagForm = ref({ tag_id: null, label_basis: '' })

const levelTagMap = { '严重': 'danger', '较重': 'warning', '一般': 'info', '轻微': 'success' }

function formatDate(val) {
  if (!val) return ''
  return val.replace('T', ' ').substring(0, 16)
}

async function loadData() {
  loading.value = true
  try {
    const res = await getEvent(eventId)
    const d = res.data || res || {}
    eventData.value = d
    tasks.value = d.tasks || []
    tags.value = d.tags || []
    factors.value = d.factors || []
    evidence.value = d.evidence || []
    try {
      const tagRes = await getTagDict()
      const td = tagRes.data || tagRes || []
      tagDictList.value = Array.isArray(td) ? td : (td.list || [])
    } catch { tagDictList.value = [] }
  } catch { /* handled */ } finally {
    loading.value = false
  }
}

async function submitTask() {
  try {
    await addEventTask(eventId, taskForm.value)
    ElMessage.success('任务添加成功')
    taskDialogVisible.value = false
    loadData()
  } catch { /* handled */ }
}

async function submitTag() {
  try {
    await addEventTag(eventId, tagForm.value)
    ElMessage.success('标签添加成功')
    tagDialogVisible.value = false
    loadData()
  } catch { /* handled */ }
}

onMounted(loadData)
</script>

<style scoped>
.event-detail { display: flex; flex-direction: column; gap: 16px; }
.page-header { display: flex; align-items: center; gap: 12px; }
.page-header h2 { font-size: 20px; color: #303133; margin: 0; }
.tab-toolbar { margin-bottom: 12px; }
.raw-text { white-space: pre-wrap; line-height: 1.8; color: #606266; font-size: 14px; }
</style>
