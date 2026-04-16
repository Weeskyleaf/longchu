<template>
  <div>
    <div class="page-header">
      <h2>新建分析案例</h2>
      <el-button @click="$router.back()">返回</el-button>
    </div>

    <el-card shadow="never">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" style="max-width: 800px">
        <el-divider content-position="left">案例信息</el-divider>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="案例编号" prop="case_no">
              <el-input v-model="form.case_no" placeholder="请输入案例编号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="案例名称" prop="case_name">
              <el-input v-model="form.case_name" placeholder="请输入案例名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="分析方法" prop="analysis_method">
              <el-select v-model="form.analysis_method" placeholder="请选择" style="width: 100%">
                <el-option label="SPAR-H" value="SPAR-H" />
                <el-option label="THERP" value="THERP" />
                <el-option label="CREAM" value="CREAM" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分析路径">
              <el-input v-model="form.analysis_path" placeholder="请输入分析路径" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="分析人员" prop="analyst">
              <el-input v-model="form.analyst" placeholder="请输入分析人员" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="关联事件ID">
              <el-input v-model="form.event_id" placeholder="可选，关联事件ID" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">电厂与事件信息</el-divider>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="电厂名称">
              <el-input v-model="form.plant_name" placeholder="请输入电厂名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="始发事件">
              <el-input v-model="form.initiating_event" placeholder="请输入始发事件" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="基本事件">
              <el-input v-model="form.basic_event" placeholder="请输入基本事件编码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="工况">
              <el-select v-model="form.operation_condition" placeholder="请选择" style="width: 100%">
                <el-option label="满功率" value="满功率" />
                <el-option label="低功率/停堆" value="低功率/停堆" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="场景描述">
          <el-input v-model="form.context_description" type="textarea" :rows="4" placeholder="请描述分析场景" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSubmit" :loading="submitting">创建案例</el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { createCase } from '../api/analysis'

const router = useRouter()
const formRef = ref(null)
const submitting = ref(false)

const form = reactive({
  case_no: '',
  case_name: '',
  analysis_method: 'SPAR-H',
  analysis_path: '',
  analyst: '',
  event_id: '',
  plant_name: '',
  initiating_event: '',
  basic_event: '',
  operation_condition: '满功率',
  context_description: ''
})

const rules = {
  case_no: [{ required: true, message: '请输入案例编号', trigger: 'blur' }],
  case_name: [{ required: true, message: '请输入案例名称', trigger: 'blur' }],
  analysis_method: [{ required: true, message: '请选择分析方法', trigger: 'change' }],
  analyst: [{ required: true, message: '请输入分析人员', trigger: 'blur' }]
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    await createCase(form)
    ElMessage.success('案例创建成功')
    router.push('/analysis')
  } finally {
    submitting.value = false
  }
}
</script>
