<template>
  <div v-loading="loading">
    <div class="page-header">
      <h2>事件详情</h2>
      <el-button @click="$router.back()">返回列表</el-button>
    </div>

    <!-- Section 1: 事件基本信息区 -->
    <el-card shadow="never" style="margin-bottom: 16px">
      <template #header><div class="section-title">事件基本信息</div></template>
      <el-descriptions :column="3" border>
        <el-descriptions-item label="事件编号">{{ event.event_no }}</el-descriptions-item>
        <el-descriptions-item label="事件标题">{{ event.event_title }}</el-descriptions-item>
        <el-descriptions-item label="事件类型">
          <el-tag size="small">{{ event.event_type }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="主分类">{{ event.main_category }}</el-descriptions-item>
        <el-descriptions-item label="子分类">{{ event.sub_category }}</el-descriptions-item>
        <el-descriptions-item label="机组号">{{ event.unit_no }}</el-descriptions-item>
        <el-descriptions-item label="系统编码">{{ event.system_code }}</el-descriptions-item>
        <el-descriptions-item label="发生时间">{{ event.occur_time }}</el-descriptions-item>
        <el-descriptions-item label="发现时间">{{ event.discover_time }}</el-descriptions-item>
        <el-descriptions-item label="后果等级">
          <el-tag :type="consequenceColor(event.consequence_level)" size="small">{{ event.consequence_level }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="来源类型">{{ event.source_type }}</el-descriptions-item>
        <el-descriptions-item label="运行模式">{{ event.operation_mode }}</el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- Section 2: 结构化展示区 -->
    <el-card shadow="never" style="margin-bottom: 16px">
      <template #header><div class="section-title">结构化展示</div></template>
      <el-row :gutter="16">
        <el-col :span="12">
          <h4 style="margin-bottom: 12px; color: #606266">标签信息</h4>
          <el-table :data="event.tags || []" border size="small" empty-text="暂无标签数据">
            <el-table-column prop="tag_type" label="标签类型" width="100" />
            <el-table-column prop="tag_name" label="标签名称" />
            <el-table-column prop="tag_value" label="标签值" />
            <el-table-column prop="review_status" label="审核状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.review_status === '已审核' ? 'success' : 'warning'" size="small">
                  {{ row.review_status }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-col>
        <el-col :span="12">
          <h4 style="margin-bottom: 12px; color: #606266">影响因素</h4>
          <el-table :data="event.factors || []" border size="small" empty-text="暂无因素数据">
            <el-table-column prop="factor_category" label="因素分类" width="100" />
            <el-table-column prop="factor_name" label="因素名称" />
            <el-table-column prop="factor_level" label="因素等级" width="80" />
            <el-table-column prop="factor_value" label="因素值" width="80" />
          </el-table>
        </el-col>
      </el-row>
    </el-card>

    <!-- Section 3: 事件经过信息区 -->
    <el-card shadow="never" style="margin-bottom: 16px">
      <template #header><div class="section-title">事件经过信息</div></template>
      <div style="margin-bottom: 16px">
        <h4 style="margin-bottom: 8px; color: #606266">事件摘要</h4>
        <div class="text-block">{{ event.event_summary || '暂无摘要信息' }}</div>
      </div>
      <div style="margin-bottom: 16px">
        <h4 style="margin-bottom: 8px; color: #606266">事件进展序列</h4>
        <div class="text-block">{{ event.event_sequence || '暂无进展序列' }}</div>
      </div>
      <div>
        <h4 style="margin-bottom: 12px; color: #606266">任务映射结果</h4>
        <el-table :data="event.tasks || []" border size="small" empty-text="暂无任务数据">
          <el-table-column prop="task_no" label="任务编号" width="120" />
          <el-table-column prop="task_name" label="任务名称" />
          <el-table-column prop="task_type" label="任务类型" width="100" />
          <el-table-column prop="operator_role" label="操作人员角色" width="120" />
          <el-table-column prop="error_type" label="失误类型" width="100" />
          <el-table-column prop="error_detail" label="失误描述" show-overflow-tooltip />
        </el-table>
      </div>
    </el-card>

    <!-- Section 4: 证据链区 -->
    <el-card shadow="never">
      <template #header><div class="section-title">证据链</div></template>
      <el-table :data="event.evidence || []" border size="small" empty-text="暂无证据数据">
        <el-table-column prop="source_type" label="来源类型" width="120" />
        <el-table-column prop="audit_status" label="审核状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.audit_status === '已审核' ? 'success' : 'warning'" size="small">
              {{ row.audit_status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="annotation_basis" label="标注依据" show-overflow-tooltip />
        <el-table-column prop="version_info" label="版本信息" width="120" />
        <el-table-column prop="operation_time" label="操作时间" width="160" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getEvent } from '../api/events'

const route = useRoute()
const loading = ref(false)
const event = ref({})

function consequenceColor(level) {
  const map = { '严重': 'danger', '较大': 'warning', '一般': 'info', '轻微': 'success' }
  return map[level] || 'info'
}

async function fetchDetail() {
  loading.value = true
  try {
    const res = await getEvent(route.params.id)
    event.value = res.data || {}
  } catch {
    event.value = {}
  } finally {
    loading.value = false
  }
}

onMounted(fetchDetail)
</script>

<style scoped>
.text-block {
  padding: 12px;
  background: #f5f7fa;
  border-radius: 4px;
  line-height: 1.8;
  color: #606266;
  white-space: pre-wrap;
}
</style>
