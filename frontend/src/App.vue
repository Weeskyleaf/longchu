<template>
  <el-container class="app-container">
    <el-aside :width="isCollapse ? '64px' : '220px'" class="app-aside">
      <div class="logo-area">
        <el-icon :size="24" color="#409EFF"><Monitor /></el-icon>
        <span v-show="!isCollapse" class="logo-text">核电人因数据库</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :router="true"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
        class="app-menu"
      >
        <el-sub-menu index="event-group">
          <template #title>
            <el-icon><Document /></el-icon>
            <span>人因事件分析</span>
          </template>
          <el-menu-item index="/events">
            <el-icon><Notebook /></el-icon>
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
            <el-icon><FolderOpened /></el-icon>
            <span>分析案例</span>
          </el-menu-item>
          <el-menu-item index="/sparh-calc">
            <el-icon><SetUp /></el-icon>
            <span>SPAR-H计算</span>
          </el-menu-item>
        </el-sub-menu>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header class="app-header">
        <div class="header-left">
          <el-icon class="collapse-btn" @click="isCollapse = !isCollapse">
            <Fold v-if="!isCollapse" />
            <Expand v-else />
          </el-icon>
          <span class="header-title">核电人因数据库系统</span>
        </div>
        <div class="header-right">
          <el-dropdown>
            <span class="user-info">
              <el-icon><UserFilled /></el-icon>
              管理员
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item>个人设置</el-dropdown-item>
                <el-dropdown-item divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="app-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

const isCollapse = ref(false)
const route = useRoute()

const activeMenu = computed(() => {
  const path = route.path
  if (path.startsWith('/events')) return '/events'
  if (path.startsWith('/statistics')) return '/statistics'
  if (path.startsWith('/analysis')) return '/analysis'
  if (path.startsWith('/sparh-calc')) return '/sparh-calc'
  return path
})
</script>

<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body, #app { height: 100%; }

.app-container {
  height: 100vh;
}

.app-aside {
  background-color: #304156;
  transition: width 0.3s;
  overflow: hidden;
}

.logo-area {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.logo-text {
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  white-space: nowrap;
}

.app-menu {
  border-right: none;
}

.app-menu:not(.el-menu--collapse) {
  width: 220px;
}

.app-header {
  background: #fff;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  height: 60px;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collapse-btn {
  font-size: 20px;
  cursor: pointer;
  color: #333;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  color: #606266;
  font-size: 14px;
}

.app-main {
  background: #f0f2f5;
  padding: 20px;
  overflow-y: auto;
}
</style>
