<template>
  <div class="analysis-list">
    <el-card shadow="never" class="search-card">
      <el-form :model="query" inline>
        <el-form-item label="分析方法">
          <el-select v-model="query.method_code" placeholder="全部" clearable style="width: 140px">
            <el-option label="SPAR-H" value="SPAR-H" />
          </el-select>
        </el-form-item>
        <el-form-item label="分析路径">
          <el-select v-model="query.analysis_path" placeholder="全部" clearable style="width: 140px">
            <el-option label="正向分析" value="正向分析" />
            <el-option label="逆向分析" value="逆向分析" />
          </el-select>
        </el-form-item>
        <el-form-item label="审核状态">
          <el-select v-model="query.review_status" placeholder="全部" clearable style="width: 120px">
            <el-option label="草稿" value="draft" />
            <el-option label="待审核" value="pending" />
            <el-option label="已审核" value="approved" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="query.keyword" placeholder="搜索案例名称..." clearable style="width: 180px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData"><el-icon><Search /></el-icon> 搜索</el-button>
          <el-button @click="resetQuery"><el-icon><Refresh /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" class="table-card">
      <template #header>
        <div class="card-header">
          <span class="card-title">分析案例</span>
          <el-button type="primary" @click="$router.push('/analysis/create')">
            <el-icon><Plus /></el-icon> 新建案例
          </el-button>
        </div>
      </template>

      <el-table :data="tableData" v-loading="loading" stripe border style="width: 100%">
        <el-table-column prop="case_code" label="案例编号" width="160" show-overflow-tooltip />
        <el-table-column prop="case_name" label="案例名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="method_code" label="分析方法" width="110" align="center">
          <template #default="{ row }">
            <el-tag type="primary" size="small">{{ row.method_code }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="analysis_path" label="分析路径" width="110" align="center" />
        <el-table-column prop="analyst" label="分析人员" width="110" align="center" />
        <el-table-column prop="review_status" label="审核状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="statusMap[row.review_status]?.type || 'info'" size="small">
              {{ statusMap[row.review_status]?.label || row.review_status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="170" align="center">
          <template #default="{ row }">{{ formatDate(row.created_at) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="240" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="$router.push(`/analysis/${row.id}`)">查看</el-button>
            <el-button type="success" link size="small" @click="handleCalc(row)">计算</el-button>
            <el-popconfirm title="确认删除该案例？" @confirm="handleDelete(row.id)">
              <template #reference>
                <el-button type="danger" link size="small">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          :current-page="pagination.page"
          :page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCases, deleteCase, calculateCase } from '@/api/analysis'
import { ElMessage } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const tableData = ref([])
const query = reactive({ method_code: '', analysis_path: '', review_status: '', keyword: '' })
const pagination = reactive({ page: 1, pageSize: 20, total: 0 })
const statusMap = {
  draft: { label: '草稿', type: 'info' },
  pending: { label: '待审核', type: 'warning' },
  approved: { label: '已审核', type: 'success' },
}

function formatDate(val) {
  if (!val) return ''
  return val.replace('T', ' ').substring(0, 16)
}

function resetQuery() {
  Object.assign(query, { method_code: '', analysis_path: '', review_status: '', keyword: '' })
  pagination.page = 1
  fetchData()
}

function handleSizeChange(val) {
  pagination.pageSize = val
  pagination.page = 1
  fetchData()
}

function handlePageChange(val) {
  pagination.page = val
  fetchData()
}

async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      pageSize: pagination.pageSize,
      ...Object.fromEntries(Object.entries(query).filter(([, v]) => v)),
    }
    const res = await getCases(params)
    const d = res.data || res || {}
    tableData.value = Array.isArray(d) ? d : (d.list || [])
    pagination.total = d.total ?? tableData.value.length
  } catch {
    tableData.value = []
  } finally {
    loading.value = false
  }
}

async function handleCalc(row) {
  try {
    await calculateCase(row.id)
    ElMessage.success('计算完成')
    router.push(`/analysis/${row.id}`)
  } catch { /* handled */ }
}

async function handleDelete(id) {
  try {
    await deleteCase(id)
    ElMessage.success('删除成功')
    fetchData()
  } catch { /* handled */ }
}

onMounted(fetchData)
</script>

<style scoped>
.analysis-list { display: flex; flex-direction: column; gap: 16px; }
.search-card :deep(.el-card__body) { padding-bottom: 2px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.card-title { font-size: 16px; font-weight: 600; color: #303133; }
.pagination-wrap { display: flex; justify-content: flex-end; margin-top: 16px; }
</style>
