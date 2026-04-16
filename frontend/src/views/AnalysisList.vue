<template>
  <div>
    <div class="page-header">
      <h2>分析案例</h2>
      <el-button type="primary" @click="$router.push('/analysis/create')">
        <el-icon><Plus /></el-icon> 新建案例
      </el-button>
    </div>

    <el-card shadow="never" class="search-card">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="案例名称">
          <el-input v-model="searchForm.keyword" placeholder="搜索案例" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="分析方法">
          <el-select v-model="searchForm.method" placeholder="全部" clearable style="width: 140px">
            <el-option label="SPAR-H" value="SPAR-H" />
            <el-option label="THERP" value="THERP" />
            <el-option label="CREAM" value="CREAM" />
          </el-select>
        </el-form-item>
        <el-form-item label="审核状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable style="width: 120px">
            <el-option label="已审核" value="已审核" />
            <el-option label="待审核" value="待审核" />
            <el-option label="草稿" value="草稿" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" style="margin-top: 16px">
      <el-table :data="tableData" v-loading="loading" stripe border style="width: 100%">
        <el-table-column prop="case_no" label="案例编号" width="140" />
        <el-table-column prop="case_name" label="案例名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="analysis_method" label="分析方法" width="110">
          <template #default="{ row }">
            <el-tag size="small">{{ row.analysis_method }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="analysis_path" label="分析路径" width="120" />
        <el-table-column prop="analyst" label="分析人员" width="100" />
        <el-table-column prop="review_status" label="审核状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.review_status === '已审核' ? 'success' : row.review_status === '待审核' ? 'warning' : 'info'" size="small">
              {{ row.review_status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="160" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="$router.push(`/analysis/${row.id}`)">查看</el-button>
            <el-button link type="success" size="small" @click="handleCalculate(row)">计算</el-button>
            <el-popconfirm title="确定删除该案例吗？" @confirm="handleDelete(row)">
              <template #reference>
                <el-button link type="danger" size="small">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <div style="display: flex; justify-content: flex-end; margin-top: 16px">
        <el-pagination
          :current-page="pagination.page"
          :page-size="pagination.pageSize"
          :page-sizes="[10, 20, 50]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getCases, deleteCase, calculateCase } from '../api/analysis'

const router = useRouter()
const loading = ref(false)
const tableData = ref([])

const searchForm = reactive({ keyword: '', method: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 0 })

async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      pageSize: pagination.pageSize,
      keyword: searchForm.keyword || undefined,
      method: searchForm.method || undefined,
      status: searchForm.status || undefined
    }
    const res = await getCases(params)
    tableData.value = res.data?.list || []
    pagination.total = res.data?.total || 0
  } catch {
    tableData.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  pagination.page = 1
  fetchData()
}

function handleReset() {
  searchForm.keyword = ''
  searchForm.method = ''
  searchForm.status = ''
  handleSearch()
}

function handleSizeChange(val) {
  pagination.pageSize = val
  pagination.page = 1
  fetchData()
}

function handleCurrentChange(val) {
  pagination.page = val
  fetchData()
}

async function handleCalculate(row) {
  try {
    await calculateCase(row.id)
    ElMessage.success('计算完成')
    router.push(`/analysis/${row.id}`)
  } catch { /* error handled by interceptor */ }
}

async function handleDelete(row) {
  try {
    await deleteCase(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch { /* error handled by interceptor */ }
}

onMounted(fetchData)
</script>
