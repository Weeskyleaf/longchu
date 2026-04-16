# 核电人因数据库系统 (V1 - Node.js)

Nuclear Power Human Factors Database System

基于论文《核电人因数据库系统设计与实现》构建的 Web 化平台，融合**人因事件分析**与**人因可靠性分析（SPAR-H）**两大子系统。

> V2 版本（Spring Boot/Maven）请切换到 `v2-springboot` 分支：`git checkout v2-springboot`

---

## 系统架构

```
┌─────────────────────────────────────────────────────────┐
│              展现层 (Vue 3 + Element Plus + ECharts)       │
│    事件台账 │ 事件详情 │ 统计分析 │ 分析案例 │ SPAR-H计算器  │
│    Port: 8080                                            │
├──────────────────────┬──────────────────────────────────┤
│  业务调度层 (Express)  │  核心计算层 (Flask)               │
│  Port: 3000           │  Port: 5001                      │
│  事件/任务/标签/证据链  │  SPAR-H HEP计算                  │
│  分析案例管理           │  五级相关性修正                    │
│  用户权限               │  Beta分布不确定性分析              │
├──────────────────────┴──────────────────────────────────┤
│              数据持久化层 (SQLite)                         │
│  17 张数据表 — 对应论文表 3.1-3.9 & 4.1-4.5               │
└─────────────────────────────────────────────────────────┘
```

---

## 技术栈

| 层次 | 技术 | 说明 |
|------|------|------|
| 前端 | Vue 3 + Element Plus + ECharts | 交互界面与可视化 |
| 后端 | Express.js (Node.js) | RESTful API 与业务调度 |
| 计算层 | Flask (Python) + SciPy | SPAR-H 量化算法 |
| 数据库 | SQLite (better-sqlite3) | 结构化数据持久化，零配置 |

---

## 环境准备

> V1 不需要 Java、Maven 或 MySQL。使用 SQLite 数据库，零配置。

### macOS

```bash
# 安装 Node.js
brew install node
node -v   # 应显示 v16+

# 安装 Python 3（macOS 通常自带）
brew install python3
python3 --version   # 应显示 Python 3.9+
```

### Windows

**安装 Node.js：**

从 [Node.js 官网](https://nodejs.org/) 下载 LTS 版本安装包（.msi），默认安装即可。

验证（打开新的命令提示符）：

```cmd
node -v
npm -v
```

**安装 Python 3：**

从 [Python 官网](https://www.python.org/downloads/) 下载安装包，**安装时务必勾选 "Add Python to PATH"**。

验证：

```cmd
python --version
pip --version
```

> Windows 下使用 `python` 和 `pip` 命令（不带 `3` 后缀）。

---

## 快速开始

### 第一步：克隆项目

```bash
git clone https://github.com/Weeskyleaf/longchu.git
cd longchu
```

> main 分支就是 V1 版本，无需切换。

### 第二步：安装依赖

**macOS / Linux：**

```bash
cd backend && npm install && cd ..
cd spar-h-service && pip3 install -r requirements.txt && cd ..
cd frontend && npm install && cd ..
```

**Windows：**

```cmd
cd backend && npm install && cd ..
cd spar-h-service && pip install -r requirements.txt && cd ..
cd frontend && npm install && cd ..
```

> macOS 上如果 `npm install` 报 `node-gyp` 错误，先运行 `pip3 install setuptools` 再重试。
> Windows 上如果报 node-gyp 错误，运行 `npm install --global windows-build-tools`。

### 第三步：启动服务（需要 3 个终端窗口）

**终端 1 — 启动 SPAR-H 计算服务（端口 5001）**

```bash
cd spar-h-service
python3 app.py          # macOS/Linux
python app.py           # Windows
```

看到 `Running on http://127.0.0.1:5001` 表示成功。

**终端 2 — 启动后端 API 服务（端口 3000）**

```bash
cd backend
npm start
```

看到 `数据库已就绪，共 10 条事件记录` 表示成功。首次启动自动创建 SQLite 数据库。

**终端 3 — 启动前端开发服务器（端口 8080）**

```bash
cd frontend
npm run dev
```

看到 `Local: http://127.0.0.1:8080/` 表示成功。

### 第四步：访问系统

浏览器打开 **http://localhost:8080**

默认账户：`admin / admin123`

---

## 项目结构

```
longchu/
├── sql/                    # MySQL 兼容建表脚本（可选）
│   └── init.sql
├── backend/                # Express.js 后端
│   ├── package.json
│   ├── data/               # SQLite 数据库文件（自动生成）
│   │   └── nuclear_hf.db
│   └── src/
│       ├── app.js          # 主入口（端口 3000）
│       ├── config/
│       │   └── database.js # SQLite 建表 + 种子数据
│       ├── middleware/
│       │   └── auth.js     # JWT 认证中间件
│       └── routes/
│           ├── events.js   # 事件管理（CRUD + 统计）
│           ├── tasks.js    # 任务单元
│           ├── tags.js     # 标签字典 + 事件绑定
│           ├── factors.js  # 影响因素评估
│           ├── persons.js  # 人员管理
│           ├── evidence.js # 证据链
│           ├── analysis.js # HRA 分析案例
│           └── users.js    # 用户认证
├── spar-h-service/         # Flask SPAR-H 计算微服务
│   ├── app.py              # Flask 入口（端口 5001）
│   ├── spar_h_engine.py    # 核心计算引擎
│   ├── routes.py           # 计算 API 路由
│   └── requirements.txt    # Python 依赖
└── frontend/               # Vue 3 前端
    ├── package.json
    ├── vite.config.js      # Vite 配置（代理 /api → 3000）
    └── src/
        ├── App.vue         # 深蓝侧边栏 + 白色主区域布局
        ├── router/         # 路由配置
        ├── api/            # Axios API 封装
        └── views/
            ├── events/     # 事件台账、详情、创建
            ├── statistics/ # 统计分析（ECharts 可视化）
            └── analysis/   # 分析案例、SPAR-H 计算器
```

---

## 数据库设计（17 张表）

**人因事件分析子系统（论文表 3.1-3.9）：**

| 表名 | 说明 | 论文表号 |
|------|------|----------|
| event_main | 事件主表 | 表3.1 |
| task_unit | 任务单元表 | 表3.2 |
| scenario_info | 场景信息表 | 表3.3 |
| tag_dict | 标签字典表 | 表3.4 |
| event_tag | 事件标签关联表 | 表3.5 |
| impact_factor | 影响因素评估表 | 表3.6 |
| person_info | 涉事人员表 | 表3.7 |
| event_person | 事件人员关联表 | 表3.8 |
| evidence_chain | 证据链表 | 表3.9 |

**人因可靠性分析子系统（论文表 4.1-4.5）：**

| 表名 | 说明 | 论文表号 |
|------|------|----------|
| analysis_case | 分析案例主表 | 表4.1 |
| sparh_psf_dict | SPAR-H 绩效因子表 | 表4.2 |
| evidence_index | 证据索引表 | 表4.3 |
| dependency_assessment | 相关性评估表 | 表4.4 |
| uncertainty_result | 不确定性处理表 | 表4.5 |
| case_task | 案例任务表 | — |
| case_psf_value | 案例PSF赋值记录 | — |

**系统管理：** sys_user

---

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
- 负向 PSF >= 3 时的调整公式
- 五级相关性模型修正
- Beta 分布不确定性分析（CNI 先验）
- PSF 影响因素柱状图 + Beta 概率密度函数曲线

---

## SPAR-H 计算验证

论文中的 LOCA 事件测试用例（表4.6）：

| PSF | 诊断 | 动作 |
|-----|------|------|
| 基础值（名义HEP） | 0.01 | 0.001 |
| 时间 | 0.01 | 0.01 |
| 压力 | 5 | 2 |
| 复杂度 | 1 | 1 |
| 经验/培训 | 0.5 | 0.5 |
| 规程 | 0.5 | 1 |
| 工效学/人机界面 | 1 | 1 |
| 职责适宜 | 1 | 1 |
| 工序 | 1 | 1 |

**计算结果：联合人误概率 = 1.35E-4** （与论文一致）

---

## 常见问题

### Q: `npm install` 报 node-gyp / distutils 错误

**macOS/Linux：**

```bash
pip3 install setuptools
cd backend && rm -rf node_modules && npm install
```

**Windows：**

```cmd
npm install --global windows-build-tools
cd backend && rmdir /s /q node_modules && npm install
```

或安装 [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)，勾选"C++ 生成工具"。

### Q: 端口被占用

**macOS/Linux：**

```bash
lsof -ti:3000 | xargs kill -9
lsof -ti:5001 | xargs kill -9
lsof -ti:8080 | xargs kill -9
```

**Windows（管理员 CMD）：**

```cmd
netstat -ano | findstr :3000
taskkill /PID <PID号> /F

netstat -ano | findstr :5001
taskkill /PID <PID号> /F

netstat -ano | findstr :8080
taskkill /PID <PID号> /F
```

### Q: Windows 上 python3 命令不存在

Windows 安装 Python 后命令是 `python` 而非 `python3`，`pip` 而非 `pip3`。启动 Flask 用：

```cmd
python app.py
```

### Q: 想重置数据库

**macOS/Linux：**

```bash
rm backend/data/nuclear_hf.db
# 重启后端会自动重新创建
```

**Windows：**

```cmd
del backend\data\nuclear_hf.db
```

### Q: 如何切换到 V2（Spring Boot）版本

```bash
git checkout v2-springboot
# 需要 Java 17 + Maven，详见 v2 分支 README
```

---

## 参考文献

- NUREG/CR-6883: The SPAR-H Human Reliability Analysis Method
- NB/T 20642—2023: 核电厂人因可靠性分析导则
