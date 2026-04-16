-- ============================================================
-- 核电人因数据库系统 - 数据库初始化脚本
-- Nuclear Power Human Factors Database System
-- ============================================================

CREATE DATABASE IF NOT EXISTS nuclear_hf DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE nuclear_hf;

-- ============================================================
-- 第一部分：人因事件分析数据库系统
-- ============================================================

-- 表3.1 事件主表
CREATE TABLE event_main (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    event_code      VARCHAR(64)     NOT NULL UNIQUE,
    event_title     VARCHAR(200)    NOT NULL,
    event_type      VARCHAR(50)     NOT NULL,
    main_category   VARCHAR(50)     NOT NULL,
    sub_category    VARCHAR(50)     NULL,
    occur_time      DATETIME        NOT NULL,
    plant_name      VARCHAR(100)    NULL,
    unit_no         VARCHAR(20)     NOT NULL,
    system_name     VARCHAR(100)    NULL,
    operation_mode  VARCHAR(50)     NULL,
    consequence_level VARCHAR(50)   NULL,
    event_result    VARCHAR(200)    NULL,
    source_type     VARCHAR(50)     NOT NULL,
    raw_text        LONGTEXT        NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 表3.2 任务单元表
CREATE TABLE task_unit (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    event_id        BIGINT          NOT NULL,
    task_code       VARCHAR(64)     NOT NULL UNIQUE,
    task_name       VARCHAR(200)    NOT NULL,
    task_type       VARCHAR(30)     NOT NULL,
    task_stage      VARCHAR(30)     NOT NULL,
    operation_object VARCHAR(100)   NULL,
    procedure_ref   VARCHAR(100)    NULL,
    available_time  DECIMAL(10,2)   NULL,
    start_condition TEXT            NULL,
    end_condition   TEXT            NULL,
    task_desc       TEXT            NULL,
    FOREIGN KEY (event_id) REFERENCES event_main(id) ON DELETE CASCADE
);

-- 表3.3 场景信息表
CREATE TABLE scenario_info (
    id                      BIGINT          AUTO_INCREMENT PRIMARY KEY,
    event_id                BIGINT          NOT NULL,
    task_id                 BIGINT          NULL,
    scenario_name           VARCHAR(100)    NOT NULL,
    system_state            VARCHAR(100)    NOT NULL,
    environmental_condition TEXT            NULL,
    interface_state         TEXT            NULL,
    procedure_state         VARCHAR(100)    NULL,
    time_pressure_desc      VARCHAR(100)    NULL,
    remark                  VARCHAR(255)    NULL,
    FOREIGN KEY (event_id) REFERENCES event_main(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id)  REFERENCES task_unit(id) ON DELETE SET NULL
);

-- 表3.4 标签字典表
CREATE TABLE tag_dict (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    tag_type        VARCHAR(30)     NOT NULL,
    tag_code        VARCHAR(64)     NOT NULL UNIQUE,
    tag_name        VARCHAR(50)     NOT NULL,
    tag_value       VARCHAR(100)    NOT NULL,
    description     TEXT            NULL,
    standard_ref    VARCHAR(255)    NULL,
    is_active       TINYINT         NOT NULL DEFAULT 1
);

-- 表3.5 事件标签关联表
CREATE TABLE event_tag (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    event_id        BIGINT          NOT NULL,
    task_id         BIGINT          NULL,
    tag_id          BIGINT          NOT NULL,
    label_basis     TEXT            NULL,
    reviewer        VARCHAR(100)    NULL,
    review_status   VARCHAR(30)     NOT NULL DEFAULT 'pending',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES event_main(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id)  REFERENCES task_unit(id) ON DELETE SET NULL,
    FOREIGN KEY (tag_id)   REFERENCES tag_dict(id) ON DELETE CASCADE
);

-- 表3.6 影响因素评估表
CREATE TABLE impact_factor (
    id                  BIGINT          AUTO_INCREMENT PRIMARY KEY,
    event_id            BIGINT          NOT NULL,
    task_id             BIGINT          NULL,
    factor_category     VARCHAR(50)     NOT NULL,
    factor_name         VARCHAR(100)    NOT NULL,
    factor_level        VARCHAR(50)     NULL,
    factor_value        VARCHAR(100)    NULL,
    assessment_basis    TEXT            NULL,
    data_source         VARCHAR(50)     NULL,
    method_mapping      VARCHAR(50)     NULL,
    remark              VARCHAR(255)    NULL,
    FOREIGN KEY (event_id) REFERENCES event_main(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id)  REFERENCES task_unit(id) ON DELETE SET NULL
);

-- 表3.7 涉事人员表
CREATE TABLE person_info (
    id                  BIGINT          AUTO_INCREMENT PRIMARY KEY,
    person_code         VARCHAR(64)     NOT NULL UNIQUE,
    person_name         VARCHAR(100)    NOT NULL,
    department          VARCHAR(100)    NULL,
    role_name           VARCHAR(50)     NULL,
    experience_years    DECIMAL(4,1)    NULL,
    qualification_level VARCHAR(50)     NULL,
    contact_info        VARCHAR(100)    NULL,
    note                VARCHAR(255)    NULL
);

-- 表3.8 事件人员关联表
CREATE TABLE event_person (
    id                  BIGINT          AUTO_INCREMENT PRIMARY KEY,
    event_id            BIGINT          NOT NULL,
    person_id           BIGINT          NOT NULL,
    involvement_type    VARCHAR(50)     NOT NULL,
    responsibility_desc TEXT            NULL,
    behavior_note       TEXT            NULL,
    FOREIGN KEY (event_id)  REFERENCES event_main(id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES person_info(id) ON DELETE CASCADE
);

-- 表3.9 证据链表
CREATE TABLE evidence_chain (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    event_id        BIGINT          NOT NULL,
    evidence_type   VARCHAR(50)     NOT NULL,
    doc_code        VARCHAR(64)     NULL,
    doc_title       VARCHAR(255)    NULL,
    source_ref      VARCHAR(255)    NULL,
    page_tag        VARCHAR(50)     NULL,
    quote_note      TEXT            NULL,
    version_no      VARCHAR(30)     NULL,
    operator_name   VARCHAR(100)    NULL,
    operate_time    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    audit_comment   TEXT            NULL,
    FOREIGN KEY (event_id) REFERENCES event_main(id) ON DELETE CASCADE
);

-- ============================================================
-- 第二部分：人因可靠性分析数据库系统
-- ============================================================

-- 表4.1 分析案例主表
CREATE TABLE analysis_case (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    case_code       VARCHAR(64)     NOT NULL UNIQUE,
    method_code     VARCHAR(32)     NOT NULL DEFAULT 'SPAR-H',
    source_event_id BIGINT          NULL,
    source_task_id  BIGINT          NULL,
    source_scene_id BIGINT          NULL,
    analysis_path   VARCHAR(20)     NOT NULL,
    case_name       VARCHAR(200)    NOT NULL,
    analyst         VARCHAR(100)    NULL,
    review_status   VARCHAR(20)     NOT NULL DEFAULT 'draft',
    model_version   VARCHAR(32)     NULL,
    summary         TEXT            NULL,
    ext_json        JSON            NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (source_event_id) REFERENCES event_main(id) ON DELETE SET NULL,
    FOREIGN KEY (source_task_id)  REFERENCES task_unit(id) ON DELETE SET NULL,
    FOREIGN KEY (source_scene_id) REFERENCES scenario_info(id) ON DELETE SET NULL
);

-- 表4.2 SPAR-H绩效因子表 (参数字典)
CREATE TABLE sparh_psf_dict (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    psf_code        VARCHAR(32)     NOT NULL,
    psf_name        VARCHAR(100)    NOT NULL,
    plant_mode      VARCHAR(20)     NOT NULL,
    task_type       VARCHAR(20)     NOT NULL,
    level_code      VARCHAR(32)     NOT NULL,
    level_name      VARCHAR(100)    NOT NULL,
    multiplier      DECIMAL(12,6)   NOT NULL,
    is_negative     TINYINT         NOT NULL DEFAULT 0,
    definition_text TEXT            NULL,
    source_ref      VARCHAR(255)    NULL,
    UNIQUE KEY uk_psf (psf_code, plant_mode, task_type, level_code)
);

-- 案例任务表（一个案例可包含诊断+动作任务）
CREATE TABLE case_task (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    case_id         BIGINT          NOT NULL,
    task_type       VARCHAR(20)     NOT NULL,
    nominal_hep     DECIMAL(16,10)  NOT NULL,
    composite_psf   DECIMAL(16,10)  NULL,
    raw_hep         DECIMAL(16,10)  NULL,
    adjusted_hep    DECIMAL(16,10)  NULL,
    negative_count  INT             NOT NULL DEFAULT 0,
    final_hep       DECIMAL(16,10)  NULL,
    calc_note       TEXT            NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES analysis_case(id) ON DELETE CASCADE
);

-- 案例PSF赋值记录表
CREATE TABLE case_psf_value (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    case_task_id    BIGINT          NOT NULL,
    psf_code        VARCHAR(32)     NOT NULL,
    psf_name        VARCHAR(100)    NOT NULL,
    level_code      VARCHAR(32)     NOT NULL,
    level_name      VARCHAR(100)    NOT NULL,
    multiplier      DECIMAL(12,6)   NOT NULL,
    is_negative     TINYINT         NOT NULL DEFAULT 0,
    basis_text      TEXT            NULL,
    FOREIGN KEY (case_task_id) REFERENCES case_task(id) ON DELETE CASCADE
);

-- 表4.3 证据索引表
CREATE TABLE evidence_index (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    case_id         BIGINT          NOT NULL,
    case_task_id    BIGINT          NULL,
    trace_step      VARCHAR(30)     NOT NULL,
    source_table    VARCHAR(50)     NOT NULL,
    source_pk       BIGINT          NOT NULL,
    evidence_excerpt TEXT           NULL,
    attachment_uri  VARCHAR(255)    NULL,
    recorder        VARCHAR(100)    NULL,
    FOREIGN KEY (case_id)      REFERENCES analysis_case(id) ON DELETE CASCADE,
    FOREIGN KEY (case_task_id) REFERENCES case_task(id) ON DELETE SET NULL
);

-- 表4.4 相关性评估表
CREATE TABLE dependency_assessment (
    id                  BIGINT          AUTO_INCREMENT PRIMARY KEY,
    case_id             BIGINT          NOT NULL,
    from_task_id        BIGINT          NOT NULL,
    to_task_id          BIGINT          NOT NULL,
    dependency_level    VARCHAR(20)     NOT NULL,
    same_crew_flag      TINYINT         NOT NULL DEFAULT 0,
    close_in_time_flag  TINYINT         NOT NULL DEFAULT 0,
    same_location_flag  TINYINT         NOT NULL DEFAULT 0,
    same_cues_flag      TINYINT         NOT NULL DEFAULT 0,
    correction_value    DECIMAL(12,6)   NULL,
    basis_text          TEXT            NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id)       REFERENCES analysis_case(id) ON DELETE CASCADE,
    FOREIGN KEY (from_task_id)  REFERENCES case_task(id) ON DELETE CASCADE,
    FOREIGN KEY (to_task_id)    REFERENCES case_task(id) ON DELETE CASCADE
);

-- 表4.5 不确定性处理表
CREATE TABLE uncertainty_result (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    case_task_id    BIGINT          NOT NULL,
    dist_type       VARCHAR(20)     NOT NULL DEFAULT 'Beta',
    alpha_param     DECIMAL(18,8)   NULL,
    beta_param      DECIMAL(18,8)   NULL,
    error_factor    DECIMAL(12,6)   NULL,
    mean_hep        DECIMAL(16,10)  NULL,
    median_hep      DECIMAL(16,10)  NULL,
    p05             DECIMAL(16,10)  NULL,
    p50             DECIMAL(16,10)  NULL,
    p95             DECIMAL(16,10)  NULL,
    param_json      JSON            NULL,
    calc_note       TEXT            NULL,
    FOREIGN KEY (case_task_id) REFERENCES case_task(id) ON DELETE CASCADE
);

-- ============================================================
-- 用户与权限表
-- ============================================================
CREATE TABLE sys_user (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50)     NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    real_name       VARCHAR(100)    NULL,
    role            VARCHAR(30)     NOT NULL DEFAULT 'analyst',
    is_active       TINYINT         NOT NULL DEFAULT 1,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 初始化SPAR-H PSF字典数据（满功率工况）
-- ============================================================

-- 时间 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_INSUFF', '时间不足够', 1.000000, 1, 'P(failure)=1.0，直接判定失败', 'NUREG/CR-6883'),
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_BARELY', '时间刚好够(<20min)', 10.000000, 1, '可用时间少于20分钟', 'NUREG/CR-6883'),
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_NOMINAL', '通常时间(30min)', 1.000000, 0, '通常时间约30分钟', 'NUREG/CR-6883'),
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_EXTRA', '充足的时间(>60min)', 0.100000, 0, '充足的时间大于60分钟', 'NUREG/CR-6883'),
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_VAST', '很多时间(>24h)', 0.010000, 0, '大量可用时间超过24小时', 'NUREG/CR-6883');

-- 时间 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'action', 'TIME_INSUFF', '时间不足够', 1.000000, 1, 'P(failure)=1.0', 'NUREG/CR-6883'),
('TIME', '可用时间', 'full_power', 'action', 'TIME_BARELY', '可用时间=所需时间', 10.000000, 1, '可用时间刚好等于所需时间', 'NUREG/CR-6883'),
('TIME', '可用时间', 'full_power', 'action', 'TIME_NOMINAL', '通常时间', 1.000000, 0, '通常时间', 'NUREG/CR-6883'),
('TIME', '可用时间', 'full_power', 'action', 'TIME_EXTRA', '充足的时间(≥5倍所需)', 0.100000, 0, '充足的时间', 'NUREG/CR-6883'),
('TIME', '可用时间', 'full_power', 'action', 'TIME_VAST', '很多时间(≥50倍所需)', 0.010000, 0, '大量可用时间', 'NUREG/CR-6883');

-- 压力 PSF
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('STRESS', '压力', 'full_power', 'diagnosis', 'STRESS_HIGH2', '很高', 5.000000, 1, '很高的压力水平', 'NUREG/CR-6883'),
('STRESS', '压力', 'full_power', 'diagnosis', 'STRESS_HIGH', '高', 2.000000, 1, '高压力水平', 'NUREG/CR-6883'),
('STRESS', '压力', 'full_power', 'diagnosis', 'STRESS_NOMINAL', '正常', 1.000000, 0, '正常压力水平', 'NUREG/CR-6883'),
('STRESS', '压力', 'full_power', 'action', 'STRESS_HIGH2', '很高', 5.000000, 1, '很高的压力水平', 'NUREG/CR-6883'),
('STRESS', '压力', 'full_power', 'action', 'STRESS_HIGH', '高', 2.000000, 1, '高压力水平', 'NUREG/CR-6883'),
('STRESS', '压力', 'full_power', 'action', 'STRESS_NOMINAL', '正常', 1.000000, 0, '正常压力水平', 'NUREG/CR-6883');

-- 复杂度 PSF
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('COMPLEXITY', '复杂度', 'full_power', 'diagnosis', 'CMPLX_HIGH', '高度复杂', 5.000000, 1, '高度复杂的任务', 'NUREG/CR-6883'),
('COMPLEXITY', '复杂度', 'full_power', 'diagnosis', 'CMPLX_MED', '中等复杂', 2.000000, 1, '中等复杂度', 'NUREG/CR-6883'),
('COMPLEXITY', '复杂度', 'full_power', 'diagnosis', 'CMPLX_NOMINAL', '正常', 1.000000, 0, '正常复杂度', 'NUREG/CR-6883'),
('COMPLEXITY', '复杂度', 'full_power', 'diagnosis', 'CMPLX_EASY', '很容易诊断', 0.100000, 0, '非常容易诊断', 'NUREG/CR-6883'),
('COMPLEXITY', '复杂度', 'full_power', 'action', 'CMPLX_HIGH', '高度复杂', 5.000000, 1, '高度复杂的任务', 'NUREG/CR-6883'),
('COMPLEXITY', '复杂度', 'full_power', 'action', 'CMPLX_MED', '中等复杂', 2.000000, 1, '中等复杂度', 'NUREG/CR-6883'),
('COMPLEXITY', '复杂度', 'full_power', 'action', 'CMPLX_NOMINAL', '正常', 1.000000, 0, '正常复杂度', 'NUREG/CR-6883');

-- 经验/培训 PSF
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TRAINING', '经验/培训', 'full_power', 'diagnosis', 'TRAIN_LOW', '低', 10.000000, 1, '经验/培训不足', 'NUREG/CR-6883'),
('TRAINING', '经验/培训', 'full_power', 'diagnosis', 'TRAIN_NOMINAL', '正常', 1.000000, 0, '正常培训水平', 'NUREG/CR-6883'),
('TRAINING', '经验/培训', 'full_power', 'diagnosis', 'TRAIN_HIGH', '高', 0.500000, 0, '高水平培训', 'NUREG/CR-6883'),
('TRAINING', '经验/培训', 'full_power', 'action', 'TRAIN_LOW', '低', 3.000000, 1, '经验/培训不足', 'NUREG/CR-6883'),
('TRAINING', '经验/培训', 'full_power', 'action', 'TRAIN_NOMINAL', '正常', 1.000000, 0, '正常培训水平', 'NUREG/CR-6883'),
('TRAINING', '经验/培训', 'full_power', 'action', 'TRAIN_HIGH', '高', 0.500000, 0, '高水平培训', 'NUREG/CR-6883');

-- 规程 PSF
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_NONE', '无', 50.000000, 1, '没有可用规程', 'NUREG/CR-6883'),
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_INCOMPLETE', '有，但不完整', 20.000000, 1, '规程不完整', 'NUREG/CR-6883'),
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_POOR', '有，但较差', 5.000000, 1, '规程质量较差', 'NUREG/CR-6883'),
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_NOMINAL', '一般', 1.000000, 0, '一般规程', 'NUREG/CR-6883'),
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_SYMPTOM', '征兆导向规程', 0.500000, 0, '征兆导向规程', 'NUREG/CR-6883'),
('PROCEDURE', '规程', 'full_power', 'action', 'PROC_NONE', '无', 50.000000, 1, '没有可用规程', 'NUREG/CR-6883'),
('PROCEDURE', '规程', 'full_power', 'action', 'PROC_INCOMPLETE', '有，但不完整', 20.000000, 1, '规程不完整', 'NUREG/CR-6883'),
('PROCEDURE', '规程', 'full_power', 'action', 'PROC_POOR', '有，但较差', 5.000000, 1, '规程质量较差', 'NUREG/CR-6883'),
('PROCEDURE', '规程', 'full_power', 'action', 'PROC_NOMINAL', '一般', 1.000000, 0, '一般规程', 'NUREG/CR-6883');

-- 工效学/人机界面 PSF
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'diagnosis', 'ERGO_MISSING', '缺失/误导', 50.000000, 1, '人机界面信息缺失或误导', 'NUREG/CR-6883'),
('ERGONOMICS', '工效学/人机界面', 'full_power', 'diagnosis', 'ERGO_POOR', '差', 10.000000, 1, '人机界面质量差', 'NUREG/CR-6883'),
('ERGONOMICS', '工效学/人机界面', 'full_power', 'diagnosis', 'ERGO_NOMINAL', '一般', 1.000000, 0, '一般人机界面', 'NUREG/CR-6883'),
('ERGONOMICS', '工效学/人机界面', 'full_power', 'diagnosis', 'ERGO_GOOD', '好', 0.500000, 0, '良好的人机界面', 'NUREG/CR-6883'),
('ERGONOMICS', '工效学/人机界面', 'full_power', 'action', 'ERGO_MISSING', '缺失/误导', 50.000000, 1, '人机界面信息缺失或误导', 'NUREG/CR-6883'),
('ERGONOMICS', '工效学/人机界面', 'full_power', 'action', 'ERGO_POOR', '差', 10.000000, 1, '人机界面质量差', 'NUREG/CR-6883'),
('ERGONOMICS', '工效学/人机界面', 'full_power', 'action', 'ERGO_NOMINAL', '一般', 1.000000, 0, '一般人机界面', 'NUREG/CR-6883'),
('ERGONOMICS', '工效学/人机界面', 'full_power', 'action', 'ERGO_GOOD', '好', 0.500000, 0, '良好的人机界面', 'NUREG/CR-6883');

-- 职责适宜 PSF
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('FITNESS', '职责适宜', 'full_power', 'diagnosis', 'FIT_UNFIT', '不适宜', 1.000000, 1, 'P(failure)=1.0，直接判定失败', 'NUREG/CR-6883'),
('FITNESS', '职责适宜', 'full_power', 'diagnosis', 'FIT_DEGRADED', '不太适宜', 5.000000, 1, '身体或精神状态不太适宜', 'NUREG/CR-6883'),
('FITNESS', '职责适宜', 'full_power', 'diagnosis', 'FIT_NOMINAL', '正常', 1.000000, 0, '正常适宜', 'NUREG/CR-6883'),
('FITNESS', '职责适宜', 'full_power', 'action', 'FIT_UNFIT', '不适宜', 1.000000, 1, 'P(failure)=1.0', 'NUREG/CR-6883'),
('FITNESS', '职责适宜', 'full_power', 'action', 'FIT_DEGRADED', '不太适宜', 5.000000, 1, '身体或精神状态不太适宜', 'NUREG/CR-6883'),
('FITNESS', '职责适宜', 'full_power', 'action', 'FIT_NOMINAL', '正常', 1.000000, 0, '正常适宜', 'NUREG/CR-6883');

-- 工序 PSF
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCESS', '工序', 'full_power', 'diagnosis', 'PROC_POOR', '差', 5.000000, 1, '工序组织差', 'NUREG/CR-6883'),
('PROCESS', '工序', 'full_power', 'diagnosis', 'PROC_NOMINAL', '一般', 1.000000, 0, '一般工序', 'NUREG/CR-6883'),
('PROCESS', '工序', 'full_power', 'diagnosis', 'PROC_GOOD', '好', 0.800000, 0, '良好的工序', 'NUREG/CR-6883'),
('PROCESS', '工序', 'full_power', 'action', 'PROC_POOR', '差', 5.000000, 1, '工序组织差', 'NUREG/CR-6883'),
('PROCESS', '工序', 'full_power', 'action', 'PROC_NOMINAL', '一般', 1.000000, 0, '一般工序', 'NUREG/CR-6883'),
('PROCESS', '工序', 'full_power', 'action', 'PROC_GOOD', '好', 0.500000, 0, '良好的工序', 'NUREG/CR-6883');

-- 初始化默认标签字典
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref) VALUES
('error_type', 'ET001', '遗漏型失误', '遗漏', '本该完成的任务或步骤被遗漏', 'Swain分类'),
('error_type', 'ET002', '执行型失误-选择', '选择错误', '选择了错误的控制', 'Swain分类'),
('error_type', 'ET003', '执行型失误-序列', '序列错误', '操作顺序错误', 'Swain分类'),
('error_type', 'ET004', '执行型失误-时间', '时间错误', '操作时间不当', 'Swain分类'),
('error_type', 'ET005', '执行型失误-质量', '质量错误', '操作质量不达标', 'Swain分类'),
('error_type', 'ET006', '无关失误', '无关行为', '执行了与任务无关的行为', 'Swain分类'),
('cognitive_type', 'CT001', '技能型疏忽', '疏忽', '技能层面的疏忽和遗忘', 'Reason-SRK'),
('cognitive_type', 'CT002', '规则型错误', '规则错误', '规则层面的错误', 'Reason-SRK'),
('cognitive_type', 'CT003', '知识型错误', '知识错误', '知识层面的错误', 'Reason-SRK'),
('task_stage', 'TS001', '事故前', '事故前', '事故发生之前的阶段', NULL),
('task_stage', 'TS002', '事故后', '事故后', '事故发生之后的阶段', NULL),
('consequence', 'CL001', '严重', '严重', '造成重大影响', NULL),
('consequence', 'CL002', '较重', '较重', '造成较大影响', NULL),
('consequence', 'CL003', '一般', '一般', '造成一般影响', NULL),
('consequence', 'CL004', '轻微', '轻微', '造成轻微影响', NULL);

-- 初始化默认管理员
INSERT INTO sys_user (username, password_hash, real_name, role) VALUES
('admin', '$2b$10$placeholder_hash_for_password_admin', '系统管理员', 'admin');
