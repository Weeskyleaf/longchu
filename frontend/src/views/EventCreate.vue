<template>
  <div>
    <div class="page-header">
      <h2>{{ isEdit ? '编辑事件' : '新增事件' }}</h2>
      <el-button @click="$router.back()">返回</el-button>
    </div>

    <el-card shadow="never">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" style="max-width: 900px">
        <el-divider content-position="left">基本信息</el-divider>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="事件编号" prop="event_no">
              <el-input v-model="form.event_no" placeholder="请输入事件编号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="事件标题" prop="event_title">
              <el-input v-model="form.event_title" placeholder="请输入事件标题" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="事件类型" prop="event_type">
              <el-select v-model="form.event_type" placeholder="请选择" style="width: 100%">
                <el-option label="设备故障" value="设备故障" />
                <el-option label="人因失误" value="人因失误" />
                <el-option label="程序缺陷" value="程序缺陷" />
                <el-option label="组织因素" value="组织因素" />
                <el-option label="外部事件" value="外部事件" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="主分类" prop="main_category">
              <el-input v-model="form.main_category" placeholder="请输入主分类" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="子分类">
              <el-input v-model="form.sub_category" placeholder="请输入子分类" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="机组号" prop="unit_no">
              <el-input v-model="form.unit_no" placeholder="请输入机组号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统编码">
              <el-input v-model="form.system_code" placeholder="请输入系统编码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="来源类型">
              <el-select v-model="form.source_type" placeholder="请选择" style="width: 100%">
                <el-option label="运行事件报告" value="运行事件报告" />
                <el-option label="经验反馈" value="经验反馈" />
                <el-option label="不符合项" value="不符合项" />
                <el-option label="其他" value="其他" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">时间信息</el-divider>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="发生时间" prop="occur_time">
              <el-date-picker v-model="form.occur_time" type="datetime" placeholder="选择发生时间" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="发现时间">
              <el-date-picker v-model="form.discover_time" type="datetime" placeholder="选择发现时间" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">事件描述</el-divider>
        <el-form-item label="后果等级">
          <el-select v-model="form.consequence_level" placeholder="请选择" style="width: 200px">
            <el-option label="严重" value="严重" />
            <el-option label="较大" value="较大" />
            <el-option label="一般" value="一般" />
            <el-option label="轻微" value="轻微" />
          </el-select>
        </el-form-item>
        <el-form-item label="运行模式">
          <el-input v-model="form.operation_mode" placeholder="请输入运行模式" />
        </el-form-item>
        <el-form-item label="事件摘要">
          <el-input v-model="form.event_summary" type="textarea" :rows="4" placeholder="请输入事件摘要" />
        </el-form-item>
        <el-form-item label="事件进展序列">
          <el-input v-model="form.event_sequence" type="textarea" :rows="4" placeholder="请输入事件进展序列" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSubmit" :loading="submitting">保存</el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { createEvent, getEvent, updateEvent } from '../api/events'

const route = useRoute()
const router = useRouter()
const formRef = ref(null)
const submitting = ref(false)
const isEdit = ref(false)

const form = reactive({
  event_no: '',
  event_title: '',
  event_type: '',
  main_category: '',
  sub_category: '',
  unit_no: '',
  system_code: '',
  source_type: '',
  occur_time: '',
  discover_time: '',
  consequence_level: '',
  operation_mode: '',
  event_summary: '',
  event_sequence: ''
})

const rules = {
  event_no: [{ required: true, message: '请输入事件编号', trigger: 'blur' }],
  event_title: [{ required: true, message: '请输入事件标题', trigger: 'blur' }],
  event_type: [{ required: true, message: '请选择事件类型', trigger: 'change' }],
  main_category: [{ required: true, message: '请输入主分类', trigger: 'blur' }],
  unit_no: [{ required: true, message: '请输入机组号', trigger: 'blur' }],
  occur_time: [{ required: true, message: '请选择发生时间', trigger: 'change' }]
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateEvent(route.params.id, form)
      ElMessage.success('更新成功')
    } else {
      await createEvent(form)
      ElMessage.success('创建成功')
    }
    router.push('/events')
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  if (route.params.id) {
    isEdit.value = true
    try {
      const res = await getEvent(route.params.id)
      Object.assign(form, res.data)
    } catch { /* keep defaults */ }
  }
})
</script>
