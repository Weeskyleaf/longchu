<template>
  <div class="app-container">
    <aside class="sidebar">
      <div class="sidebar-title">核电人因数据库系统</div>
      <el-menu
        :default-active="activeMenu"
        :router="true"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#ffffff"
      >
        <el-sub-menu index="event-group">
          <template #title>
            <el-icon><Document /></el-icon>
            <span>人因事件分析</span>
          </template>
          <el-menu-item index="/events">
            <el-icon><List /></el-icon>
            <span>事件台账</span>
          </el-menu-item>
          <el-menu-item index="/statistics">
            <el-icon><DataAnalysis /></el-icon>
            <span>统计分析</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="analysis-group">
          <template #title>
            <el-icon><Cpu /></el-icon>
            <span>人因可靠性分析</span>
          </template>
          <el-menu-item index="/analysis">
            <el-icon><Folder /></el-icon>
            <span>分析案例</span>
          </el-menu-item>
          <el-menu-item index="/sparh-calc">
            <el-icon><Operation /></el-icon>
            <span>SPAR-H计算</span>
          </el-menu-item>
        </el-sub-menu>
      </el-menu>
    </aside>
    <div class="main-wrapper">
      <div class="main-header">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
          <el-breadcrumb-item v-if="currentRoute.meta.group">{{ currentRoute.meta.group }}</el-breadcrumb-item>
          <el-breadcrumb-item>{{ currentRoute.meta.title }}</el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      <div class="main-content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { Document, List, DataAnalysis, Cpu, Folder, Operation } from '@element-plus/icons-vue'

const route = useRoute()
const currentRoute = computed(() => route)
const activeMenu = computed(() => {
  const path = route.path
  if (path.startsWith('/events')) return '/events'
  if (path.startsWith('/statistics')) return '/statistics'
  if (path.startsWith('/analysis')) return '/analysis'
  if (path.startsWith('/sparh-calc')) return '/sparh-calc'
  return path
})
</script>
