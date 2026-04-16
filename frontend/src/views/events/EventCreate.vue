<template>
  <div class="event-create">
    <div class="page-header">
      <el-button @click="$router.back()" text>
        <el-icon><ArrowLeft /></el-icon> 返回
      </el-button>
      <h2>{{ isEdit ? '编辑事件' : '新增事件' }}</h2>
    </div>

    <el-card shadow="never">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" style="max-width: 900px">
        <h3 class="section-title">基本信息</h3>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="事件编号" prop="event_code">
              <el-input v-model="form.event_code" placeholder="如 EVT-2024-001" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="事件类型" prop="event_type">
              <el-select v-model="form.event_type" placeholder="请选择" style="width: 100%">
                <el-option label="操作事件" value="操作事件" />
                <el-option label="设备事件" value="设备事件" />
                <el-option label="管理事件" value="管理事件" />
                <el-option label="组织事件" value="组织事件" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="事件标题" prop="event_title">
          <el-input v-model="form.event_title" placeholder="请输入事件标题" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="主分类" prop="main_category">
              <el-input v-model="form.main_category" placeholder="请输入主分类" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="子分类">
              <el-input v-model="form.sub_category" placeholder="请输入子分类（可选）" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="发生时间" prop="occur_time">
              <el-date-picker v-model="form.occur_time" type="datetime" placeholder="请选择时间" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="机组号" prop="unit_no">
              <el-input v-model="form.unit_no" placeholder="如 1号机组" />
            </el-form-item>
          </el-col>
        </el-row>

        <h3 class="section-title">事件详情</h3>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="电厂名称">
              <el-input v-model="form.plant_name" placeholder="请输入电厂名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="系统名称">
              <el-input v-model="form.system_name" placeholder="请输入系统名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="运行模式">
              <el-select v-model="form.operation_mode" placeholder="请选择" clearable style="width: 100%">
                <el-option label="满功率" value="满功率" />
                <el-option label="低功率" value="低功率" />
                <el-option label="停堆" value="停堆" />
                <el-option label="换料" value="换料" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="后果等级">
              <el-select v-model="form.consequence_level" placeholder="请选择" clearable style="width: 100%">
                <el-option label="严重" value="严重" />
                <el-option label="较重" value="较重" />
                <el-option label="一般" value="一般" />
                <el-option label="轻微" value="轻微" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="事件结果">
          <el-input v-model="form.event_result" placeholder="请简要描述事件结果" />
        </el-form-item>

        <h3 class="section-title">来源信息</h3>
        <el-form-item label="来源类型" prop="source_type">
          <el-select v-model="form.source_type" placeholder="请选择" style="width: 100%">
            <el-option label="运行经验报告" value="运行经验报告" />
            <el-option label="事件报告" value="事件报告" />
            <el-option label="NRC通报" value="NRC通报" />
            <el-option label="IAEA报告" value="IAEA报告" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="原始文本" prop="raw_text">
          <el-input v-model="form.raw_text" type="textarea" :rows="6" placeholder="请粘贴事件原始文本..." />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitForm" :loading="submitting">
            {{ isEdit ? '保存修改' : '创建事件' }}
          </el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getEvent, createEvent, updateEvent } from '@/api/events'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const editId = route.query.id
const isEdit = computed(() => !!editId)
const formRef = ref(null)
const submitting = ref(false)

const form = reactive({
  event_code: '',
  event_title: '',
  event_type: '',
  main_category: '',
  sub_category: '',
  occur_time: '',
  plant_name: '',
  unit_no: '',
  system_name: '',
  operation_mode: '',
  consequence_level: '',
  event_result: '',
  source_type: '',
  raw_text: '',
})

const rules = {
  event_code: [{ required: true, message: '请输入事件编号', trigger: 'blur' }],
  event_title: [{ required: true, message: '请输入事件标题', trigger: 'blur' }],
  event_type: [{ required: true, message: '请选择事件类型', trigger: 'change' }],
  main_category: [{ required: true, message: '请输入主分类', trigger: 'blur' }],
  occur_time: [{ required: true, message: '请选择发生时间', trigger: 'change' }],
  unit_no: [{ required: true, message: '请输入机组号', trigger: 'blur' }],
  source_type: [{ required: true, message: '请选择来源类型', trigger: 'change' }],
  raw_text: [{ required: true, message: '请输入原始文本', trigger: 'blur' }],
}

async function loadEvent() {
  if (!editId) return
  try {
    const res = await getEvent(editId)
    const d = res.data || res
    Object.keys(form).forEach((k) => { if (d[k] !== undefined) form[k] = d[k] })
  } catch { /* handled */ }
}

async function submitForm() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateEvent(editId, form)
      ElMessage.success('更新成功')
    } else {
      await createEvent(form)
      ElMessage.success('创建成功')
    }
    router.push('/events')
  } catch { /* handled */ } finally {
    submitting.value = false
  }
}

onMounted(loadEvent)
</script>

<style scoped>
.event-create { display: flex; flex-direction: column; gap: 16px; }
.page-header { display: flex; align-items: center; gap: 12px; }
.page-header h2 { font-size: 20px; color: #303133; margin: 0; }
.section-title {
  font-size: 15px;
  color: #303133;
  margin: 20px 0 16px;
  padding-left: 10px;
  border-left: 3px solid #409EFF;
}
.section-title:first-of-type { margin-top: 0; }
</style>
