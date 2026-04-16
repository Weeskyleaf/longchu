# 核电人因数据库系统 (V2 - Spring Boot)

Nuclear Power Human Factors Database System

基于论文《核电人因数据库系统设计与实现》构建的 Web 化平台，融合**人因事件分析**与**人因可靠性分析（SPAR-H）**两大子系统。

> V1 版本（Node.js/Express）请切换到 `main` 分支或查看 tag `v1-nodejs`

---

## 系统架构

```
┌─────────────────────────────────────────────────────────┐
│              展现层 (Vue 3 + Element Plus + ECharts)       │
│    事件台账 │ 事件详情 │ 统计分析 │ 分析案例 │ SPAR-H计算器  │
├──────────────────────┬──────────────────────────────────┤
│  业务调度层            │  核心计算层                       │
│  Java 17              │  Python 3                        │
│  Spring Boot 3.2      │  Flask                           │
│  Port: 3000           │  Port: 5001                      │
├──────────────────────┴──────────────────────────────────┤
│              数据持久化层 (H2 开发 / MySQL 8 生产)          │
│  17 张数据表 (JPA 实体) — 对应论文表 3.1-3.9 & 4.1-4.5    │
└─────────────────────────────────────────────────────────┘
```

---

## 技术栈（对应论文 3.6.1 & 4.6.1）

| 层次 | 技术 | 论文原文 |
|------|------|----------|
| 后端 | Java 17 + Spring Boot 3.2 + Maven | "后端使用Java语言和Spring Boot框架进行开发" |
| 数据库 | MySQL 8 / H2（开发） | "数据层采用MySQL关系型数据库" |
| 前端 | Vue 3 + Element Plus + ECharts | "前端基于Vue框架并结合Element UI组件库" |
| 计算层 | Flask + SciPy | "引入Flask用于实现SPAR-H算法的独立运行" |

---

## 环境准备（macOS）

### 1. 安装 JDK 17

```bash
brew install openjdk@17

# 配置环境变量（加到 ~/.zshrc）
echo 'export JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 验证
java -version
# 应显示: openjdk version "17.x.x"
```

### 2. 安装 Maven

```bash
brew install maven

# 验证
mvn -version
# 应显示: Apache Maven 3.9.x
```

### 3. 安装 Python 3 及依赖

```bash
# macOS 通常自带 python3，如果没有：
brew install python3

# 验证
python3 --version
# 应显示: Python 3.9+
```

### 4. 安装 Node.js（前端需要）

```bash
brew install node

# 验证
node -v   # 应显示 v16+
npm -v    # 应显示 9+
```

### 5.（可选）安装 MySQL 8

```bash
brew install mysql
brew services start mysql

# 创建数据库
mysql -u root -e "CREATE DATABASE nuclear_hf DEFAULT CHARACTER SET utf8mb4;"
```

> 如果不安装 MySQL，系统默认使用 H2 内存数据库，无需额外配置即可运行。

---

## 快速开始

### 第一步：克隆项目并切换到 v2 分支

```bash
git clone https://github.com/Weeskyleaf/longchu.git
cd longchu
git checkout v2-springboot
```

### 第二步：安装依赖

```bash
# 1. 后端 Maven 依赖（首次会下载较多包，耐心等待）
cd backend
mvn dependency:resolve
cd ..

# 2. SPAR-H 计算服务 Python 依赖
cd spar-h-service
pip3 install -r requirements.txt
cd ..

# 3. 前端 npm 依赖
cd frontend
npm install
cd ..
```

### 第三步：启动服务（需要 3 个终端窗口）

**终端 1 — 启动 SPAR-H 计算服务（端口 5001）**

```bash
cd spar-h-service
python3 app.py
```

看到以下输出表示成功：
```
 * Running on http://127.0.0.1:5001
```

**终端 2 — 启动 Spring Boot 后端（端口 3000）**

```bash
cd backend
mvn spring-boot:run
```

看到以下输出表示成功：
```
Tomcat started on port 3000 (http) with context path '/api'
Started NuclearHfApplication in x.xx seconds
```

> 首次启动会自动建表并导入种子数据（10 条核电站事件 + PSF 字典 + 标签字典）

**终端 3 — 启动前端开发服务器（端口 8080）**

```bash
cd frontend
npm run dev
```

看到以下输出表示成功：
```
VITE ready in xxx ms
➜  Local:   http://127.0.0.1:8080/
```

### 第四步：访问系统

浏览器打开 **http://localhost:8080**

默认账户：`admin / admin123`

---

## 使用 MySQL（生产环境）

如需切换到 MySQL 数据库：

```bash
# 1. 确保 MySQL 已启动并创建了数据库
mysql -u root -e "CREATE DATABASE IF NOT EXISTS nuclear_hf DEFAULT CHARACTER SET utf8mb4;"

# 2. 启动后端时指定 mysql profile
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=mysql

# 或者修改 application.yml 中的 MySQL 连接信息
```

可以先用 `sql/init.sql` 初始化 MySQL 表结构和数据：

```bash
mysql -u root nuclear_hf < sql/init.sql
```

---

## 项目结构

```
longchu/
├── sql/                          # MySQL 兼容建表脚本
│   └── init.sql
├── backend/                      # Spring Boot 后端
│   ├── pom.xml                   # Maven 配置
│   └── src/main/
│       ├── java/com/nuclear/hf/
│       │   ├── NuclearHfApplication.java  # 主启动类
│       │   ├── config/           # CORS、RestTemplate 配置
│       │   ├── dto/              # ApiResponse 统一响应
│       │   ├── entity/           # 17 个 JPA 实体
│       │   ├── repository/       # 17 个 Spring Data Repository
│       │   ├── service/          # 8 个业务 Service
│       │   └── controller/       # 8 个 REST Controller
│       └── resources/
│           ├── application.yml   # 服务配置（H2/MySQL 双 profile）
│           └── data.sql          # 种子数据
├── spar-h-service/               # Flask SPAR-H 计算微服务
│   ├── app.py                    # Flask 入口（端口 5001）
│   ├── spar_h_engine.py          # 核心计算引擎
│   ├── routes.py                 # 计算 API 路由
│   └── requirements.txt          # Python 依赖
└── frontend/                     # Vue 3 前端
    ├── package.json
    ├── vite.config.js            # Vite 配置（代理 /api → 3000）
    └── src/
        ├── App.vue               # 深蓝侧边栏布局
        ├── router/index.js       # 8 条路由
        ├── api/                  # Axios API 封装
        └── views/
            ├── EventList.vue     # 图3.3 事件台账
            ├── EventDetail.vue   # 图3.4/3.5 事件详情（四段式）
            ├── EventCreate.vue   # 事件新增/编辑
            ├── Statistics.vue    # 图3.6 统计分析
            ├── AnalysisList.vue  # 分析案例列表
            ├── AnalysisDetail.vue# 图4.4 三栏布局
            ├── AnalysisCreate.vue# 新建分析案例
            └── SparhCalculator.vue# SPAR-H 五步计算器
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

### Q: 启动后端报 "JAVA_HOME is not set"

```bash
export JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
```

建议将以上两行加入 `~/.zshrc` 持久化。

### Q: Maven 下载依赖很慢

在 `~/.m2/settings.xml` 中配置阿里云镜像：

```xml
<settings>
  <mirrors>
    <mirror>
      <id>aliyun</id>
      <mirrorOf>central</mirrorOf>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
```

### Q: 端口被占用

```bash
# 查看并杀掉占用端口的进程
lsof -ti:3000 | xargs kill -9   # 后端
lsof -ti:5001 | xargs kill -9   # Flask
lsof -ti:8080 | xargs kill -9   # 前端
```

### Q: 前端页面空白 / API 404

确保三个服务都已启动，且启动顺序为：Flask → Spring Boot → 前端。

### Q: 如何切换回 V1 版本

```bash
git checkout main
# V1 使用 Node.js/Express，启动方式见 main 分支 README
```

---

## 参考文献

- NUREG/CR-6883: The SPAR-H Human Reliability Analysis Method
- NB/T 20642—2023: 核电厂人因可靠性分析导则
