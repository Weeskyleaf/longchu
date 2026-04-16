<template>
  <div class="analysis-create">
    <div class="page-header">
      <el-button @click="$router.back()" text>
        <el-icon><ArrowLeft /></el-icon> 返回
      </el-button>
      <h2>新建分析案例</h2>
    </div>

    <el-card shadow="never">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" style="max-width: 800px">
        <el-form-item label="案例编号" prop="case_code">
          <el-input v-model="form.case_code" placeholder="如 ANA-2024-001" />
        </el-form-item>
        <el-form-item label="案例名称" prop="case_name">
          <el-input v-model="form.case_name" placeholder="请输入案例名称" />
        </el-form-item>
        <el-form-item label="分析方法" prop="method_code">
          <el-select v-model="form.method_code" style="width: 100%">
            <el-option label="SPAR-H" value="SPAR-H" />
          </el-select>
        </el-form-item>
        <el-form-item label="分析路径" prop="analysis_path">
          <el-radio-group v-model="form.analysis_path">
            <el-radio value="正向分析">正向分析</el-radio>
            <el-radio value="逆向分析">逆向分析</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="分析人员">
          <el-input v-model="form.analyst" placeholder="请输入分析人员姓名" />
        </el-form-item>
        <el-form-item label="案例摘要">
          <el-input v-model="form.summary" type="textarea" :rows="4" placeholder="请简要描述分析案例..." />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="submitForm" :loading="submitting">创建案例</el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { createCase } from '@/api/analysis'
import { ElMessage } from 'element-plus'

const router = useRouter()
const formRef = ref(null)
const submitting = ref(false)

const form = reactive({
  case_code: '',
  case_name: '',
  method_code: 'SPAR-H',
  analysis_path: '正向分析',
  analyst: '',
  summary: '',
})

const rules = {
  case_code: [{ required: true, message: '请输入案例编号', trigger: 'blur' }],
  case_name: [{ required: true, message: '请输入案例名称', trigger: 'blur' }],
  method_code: [{ required: true, message: '请选择分析方法', trigger: 'change' }],
  analysis_path: [{ required: true, message: '请选择分析路径', trigger: 'change' }],
}

async function submitForm() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    const res = await createCase(form)
    ElMessage.success('案例创建成功')
    router.push(`/analysis/${res.id || res.data?.id || ''}`)
  } catch { /* handled */ } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.analysis-create { display: flex; flex-direction: column; gap: 16px; }
.page-header { display: flex; align-items: center; gap: 12px; }
.page-header h2 { font-size: 20px; color: #303133; margin: 0; }
</style>
