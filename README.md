# 核电人因数据库系统

Nuclear Power Human Factors Database System

基于论文《核电人因数据库系统设计与实现》构建的 Web 化平台，融合**人因事件分析**与**人因可靠性分析（SPAR-H）**两大子系统。

## 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                   展现层 (Vue 3 + Element Plus)           │
│     事件台账 │ 统计分析 │ 分析案例 │ SPAR-H计算器          │
├──────────────────────┬──────────────────────────────────┤
│  业务调度层 (Express) │  核心计算层 (Flask)               │
│  Port: 3000          │  Port: 5001                       │
│  事件/任务/标签/证据链 │  SPAR-H HEP计算                  │
│  分析案例管理          │  五级相关性修正                    │
│  用户权限              │  Beta分布不确定性分析              │
├──────────────────────┴──────────────────────────────────┤
│              数据持久化层 (SQLite / MySQL)                 │
│  事件主表 │ 任务单元 │ 标签字典 │ 影响因素 │ 分析案例       │
│  PSF字典 │ 相关性评估 │ 不确定性结果 │ 证据链              │
└─────────────────────────────────────────────────────────┘
```

## 功能特性

### 人因事件分析数据库
- 事件录入、审核、分类标注
- 任务单元拆解与场景信息管理
- 多维度标签体系（行为分类、认知分类、情境分类）
- 影响因素评估与 PSF 关联
- 统计分析与 ECharts 可视化（饼图、柱状图、折线图）
- 证据链管理与审计追溯

### 人因可靠性分析数据库
- SPAR-H 方法完整实现
- 8 个绩效形成因子（PSF）赋值
- 诊断/动作任务 HEP 自动计算
- 负向 PSF ≥ 3 时的调整公式
- 五级相关性模型修正
- Beta 分布不确定性分析（CNI 先验）
- PSF 影响因素柱状图
- Beta 概率密度函数曲线可视化

## 技术栈

| 层次 | 技术 | 说明 |
|------|------|------|
| 前端 | Vue 3 + Element Plus + ECharts | 交互界面与可视化 |
| 业务层 | Express.js (Node.js) | RESTful API 与业务调度 |
| 计算层 | Flask (Python) + SciPy | SPAR-H 量化算法 |
| 数据库 | SQLite (开发) / MySQL (生产) | 结构化数据持久化 |

## 快速开始

### 环境要求
- Node.js >= 16
- Python >= 3.9
- pip

### 1. 安装依赖

```bash
# 后端依赖
cd backend && npm install

# SPAR-H 计算服务依赖
cd ../spar-h-service && pip install -r requirements.txt

# 前端依赖
cd ../frontend && npm install
```

### 2. 启动服务

```bash
# 终端 1 - 启动 SPAR-H 计算服务 (端口 5001)
cd spar-h-service && python3 app.py

# 终端 2 - 启动后端 API 服务 (端口 3000)
cd backend && npm start

# 终端 3 - 启动前端开发服务器 (端口 8080)
cd frontend && npm run dev
```

### 3. 访问系统

浏览器打开 http://localhost:8080

默认账户：`admin / admin123`

## 项目结构

```
longchu/
├── sql/                    # MySQL 兼容数据库脚本
│   └── init.sql
├── backend/                # Express.js 后端服务
│   └── src/
│       ├── app.js          # 主入口
│       ├── config/
│       │   └── database.js # SQLite 数据库初始化 + 种子数据
│       ├── middleware/
│       │   └── auth.js     # JWT 认证
│       └── routes/
│           ├── events.js   # 事件管理
│           ├── tasks.js    # 任务单元
│           ├── tags.js     # 标签管理
│           ├── factors.js  # 影响因素
│           ├── persons.js  # 人员管理
│           ├── evidence.js # 证据链
│           ├── analysis.js # HRA 分析案例
│           └── users.js    # 用户认证
├── spar-h-service/         # Flask SPAR-H 计算微服务
│   ├── app.py              # Flask 入口
│   ├── spar_h_engine.py    # 核心计算引擎
│   └── routes.py           # 计算 API 路由
└── frontend/               # Vue 3 前端
    └── src/
        ├── App.vue         # 布局（深蓝侧边栏 + 白色主区域）
        ├── router/         # 路由配置
        ├── api/            # API 调用封装
        └── views/
            ├── events/     # 事件台账、详情、创建
            ├── statistics/ # 统计分析可视化
            └── analysis/   # 分析案例、SPAR-H 计算器
```

## 数据库设计

系统包含 17 张核心数据表：

**事件分析子系统**: event_main, task_unit, scenario_info, tag_dict, event_tag, impact_factor, person_info, event_person, evidence_chain

**可靠性分析子系统**: analysis_case, case_task, case_psf_value, sparh_psf_dict, evidence_index, dependency_assessment, uncertainty_result

**系统管理**: sys_user

## SPAR-H 计算验证

论文中的 LOCA 事件测试用例：

| 项目 | 诊断 | 动作 |
|------|------|------|
| 基础值 | 0.01 | 0.001 |
| 时间 | 0.01 | 0.01 |
| 压力 | 5 | 2 |
| 复杂度 | 1 | 1 |
| 经验/培训 | 0.5 | 0.5 |
| 规程 | 0.5 | 1 |
| 工效学 | 1 | 1 |
| 职责适宜 | 1 | 1 |
| 工序 | 1 | 1 |

**计算结果**: 联合人误概率 = **1.35E-4** ✓（与论文一致）

## 参考文献

- NUREG/CR-6883: The SPAR-H Human Reliability Analysis Method
- NB/T 20642—2023: 核电厂人因可靠性分析导则
