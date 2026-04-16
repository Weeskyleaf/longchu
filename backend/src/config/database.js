import Database from 'better-sqlite3';
import bcrypt from 'bcryptjs';
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DB_PATH = path.join(__dirname, '..', '..', 'data', 'nuclear_hf.db');

import fs from 'fs';
fs.mkdirSync(path.dirname(DB_PATH), { recursive: true });

const db = new Database(DB_PATH);

db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// ─── Schema ────────────────────────────────────────────────────────

db.exec(`
  CREATE TABLE IF NOT EXISTS event_main (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    event_code      TEXT UNIQUE,
    event_title     TEXT NOT NULL,
    event_type      TEXT,
    main_category   TEXT,
    sub_category    TEXT,
    occur_time      TEXT,
    plant_name      TEXT,
    unit_no         TEXT,
    system_name     TEXT,
    operation_mode  TEXT,
    consequence_level TEXT,
    event_result    TEXT,
    source_type     TEXT,
    raw_text        TEXT,
    created_at      TEXT DEFAULT (datetime('now','localtime')),
    updated_at      TEXT DEFAULT (datetime('now','localtime'))
  );

  CREATE TABLE IF NOT EXISTS task_unit (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id        INTEGER REFERENCES event_main(id) ON DELETE CASCADE,
    task_code       TEXT,
    task_name       TEXT NOT NULL,
    task_type       TEXT,
    task_stage      TEXT,
    operation_object TEXT,
    procedure_ref   TEXT,
    available_time  TEXT,
    start_condition TEXT,
    end_condition   TEXT,
    task_desc       TEXT
  );

  CREATE TABLE IF NOT EXISTS scenario_info (
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id              INTEGER REFERENCES event_main(id) ON DELETE CASCADE,
    task_id               INTEGER REFERENCES task_unit(id) ON DELETE SET NULL,
    scenario_name         TEXT,
    system_state          TEXT,
    environmental_condition TEXT,
    interface_state       TEXT,
    procedure_state       TEXT,
    time_pressure_desc    TEXT,
    remark                TEXT
  );

  CREATE TABLE IF NOT EXISTS tag_dict (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    tag_type      TEXT,
    tag_code      TEXT UNIQUE,
    tag_name      TEXT NOT NULL,
    tag_value     TEXT,
    description   TEXT,
    standard_ref  TEXT,
    is_active     INTEGER DEFAULT 1
  );

  CREATE TABLE IF NOT EXISTS event_tag (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id      INTEGER REFERENCES event_main(id) ON DELETE CASCADE,
    task_id       INTEGER REFERENCES task_unit(id) ON DELETE SET NULL,
    tag_id        INTEGER REFERENCES tag_dict(id),
    label_basis   TEXT,
    reviewer      TEXT,
    review_status TEXT DEFAULT 'pending',
    created_at    TEXT DEFAULT (datetime('now','localtime'))
  );

  CREATE TABLE IF NOT EXISTS impact_factor (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id        INTEGER REFERENCES event_main(id) ON DELETE CASCADE,
    task_id         INTEGER REFERENCES task_unit(id) ON DELETE SET NULL,
    factor_category TEXT,
    factor_name     TEXT,
    factor_level    TEXT,
    factor_value    REAL,
    assessment_basis TEXT,
    data_source     TEXT,
    method_mapping  TEXT,
    remark          TEXT
  );

  CREATE TABLE IF NOT EXISTS person_info (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    person_code         TEXT UNIQUE,
    person_name         TEXT NOT NULL,
    department          TEXT,
    role_name           TEXT,
    experience_years    INTEGER,
    qualification_level TEXT,
    contact_info        TEXT,
    note                TEXT
  );

  CREATE TABLE IF NOT EXISTS event_person (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id          INTEGER REFERENCES event_main(id) ON DELETE CASCADE,
    person_id         INTEGER REFERENCES person_info(id),
    involvement_type  TEXT,
    responsibility_desc TEXT,
    behavior_note     TEXT
  );

  CREATE TABLE IF NOT EXISTS evidence_chain (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id        INTEGER REFERENCES event_main(id) ON DELETE CASCADE,
    evidence_type   TEXT,
    doc_code        TEXT,
    doc_title       TEXT,
    source_ref      TEXT,
    page_tag        TEXT,
    quote_note      TEXT,
    version_no      TEXT,
    operator_name   TEXT,
    operate_time    TEXT,
    audit_comment   TEXT
  );

  CREATE TABLE IF NOT EXISTS analysis_case (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    case_code       TEXT UNIQUE,
    method_code     TEXT DEFAULT 'SPAR-H',
    source_event_id INTEGER REFERENCES event_main(id),
    source_task_id  INTEGER,
    source_scene_id INTEGER,
    analysis_path   TEXT,
    case_name       TEXT NOT NULL,
    analyst         TEXT,
    review_status   TEXT DEFAULT 'draft',
    model_version   TEXT DEFAULT '1.0',
    summary         TEXT,
    ext_json        TEXT,
    created_at      TEXT DEFAULT (datetime('now','localtime')),
    updated_at      TEXT DEFAULT (datetime('now','localtime'))
  );

  CREATE TABLE IF NOT EXISTS case_task (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    case_id         INTEGER REFERENCES analysis_case(id) ON DELETE CASCADE,
    task_type       TEXT CHECK(task_type IN ('diagnosis','action')),
    nominal_hep     REAL,
    composite_psf   REAL,
    raw_hep         REAL,
    adjusted_hep    REAL,
    negative_count  INTEGER DEFAULT 0,
    final_hep       REAL,
    calc_note       TEXT,
    created_at      TEXT DEFAULT (datetime('now','localtime'))
  );

  CREATE TABLE IF NOT EXISTS case_psf_value (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    case_task_id  INTEGER REFERENCES case_task(id) ON DELETE CASCADE,
    psf_code      TEXT,
    psf_name      TEXT,
    level_code    TEXT,
    level_name    TEXT,
    multiplier    REAL DEFAULT 1.0,
    is_negative   INTEGER DEFAULT 0,
    basis_text    TEXT
  );

  CREATE TABLE IF NOT EXISTS sparh_psf_dict (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    psf_code        TEXT,
    psf_name        TEXT,
    plant_mode      TEXT,
    task_type       TEXT,
    level_code      TEXT,
    level_name      TEXT,
    multiplier      REAL,
    is_negative     INTEGER DEFAULT 0,
    definition_text TEXT,
    source_ref      TEXT DEFAULT 'NUREG/CR-6883'
  );

  CREATE TABLE IF NOT EXISTS evidence_index (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    case_id         INTEGER REFERENCES analysis_case(id) ON DELETE CASCADE,
    case_task_id    INTEGER REFERENCES case_task(id) ON DELETE SET NULL,
    trace_step      INTEGER,
    source_table    TEXT,
    source_pk       INTEGER,
    evidence_excerpt TEXT,
    attachment_uri  TEXT,
    recorder        TEXT
  );

  CREATE TABLE IF NOT EXISTS dependency_assessment (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    case_id             INTEGER REFERENCES analysis_case(id) ON DELETE CASCADE,
    from_task_id        INTEGER REFERENCES case_task(id),
    to_task_id          INTEGER REFERENCES case_task(id),
    dependency_level    TEXT,
    same_crew_flag      INTEGER DEFAULT 0,
    close_in_time_flag  INTEGER DEFAULT 0,
    same_location_flag  INTEGER DEFAULT 0,
    same_cues_flag      INTEGER DEFAULT 0,
    correction_value    REAL,
    basis_text          TEXT,
    created_at          TEXT DEFAULT (datetime('now','localtime'))
  );

  CREATE TABLE IF NOT EXISTS uncertainty_result (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    case_task_id  INTEGER REFERENCES case_task(id) ON DELETE CASCADE,
    dist_type     TEXT DEFAULT 'beta',
    alpha_param   REAL,
    beta_param    REAL,
    error_factor  REAL,
    mean_hep      REAL,
    median_hep    REAL,
    p05           REAL,
    p50           REAL,
    p95           REAL,
    param_json    TEXT,
    calc_note     TEXT
  );

  CREATE TABLE IF NOT EXISTS sys_user (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    real_name     TEXT,
    role          TEXT DEFAULT 'analyst',
    is_active     INTEGER DEFAULT 1,
    created_at    TEXT DEFAULT (datetime('now','localtime'))
  );
`);

// ─── Seed helpers ──────────────────────────────────────────────────

function seedIfEmpty(table, seedFn) {
  const count = db.prepare(`SELECT COUNT(*) AS c FROM ${table}`).get().c;
  if (count === 0) seedFn();
}

// ─── SPAR-H PSF Dictionary ────────────────────────────────────────

seedIfEmpty('sparh_psf_dict', () => {
  const ins = db.prepare(`INSERT INTO sparh_psf_dict
    (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text)
    VALUES (?,?,?,?,?,?,?,?,?)`);

  const modes = ['full_power'];
  const taskTypes = ['diagnosis', 'action'];

  const psfDefs = [
    {
      code: 'TIME', name: '可用时间', levels: [
        { code: 'INAD', name: '时间不足', mult: { diagnosis: 1.0, action: 1.0 }, neg: 1, def: '可用时间不足以完成任务，P(failure)=1.0' },
        { code: 'BARELY', name: '勉强充足', mult: { diagnosis: 10.0, action: 10.0 }, neg: 1, def: '可用时间约等于所需时间的2/3' },
        { code: 'NOMINAL', name: '标称时间', mult: { diagnosis: 1.0, action: 1.0 }, neg: 0, def: '可用时间等于或略大于所需时间' },
        { code: 'EXTRA', name: '额外时间', mult: { diagnosis: 0.1, action: 0.1 }, neg: 0, def: '可用时间是所需时间的两倍以上' },
        { code: 'EXPAN', name: '充裕时间', mult: { diagnosis: 0.01, action: 0.01 }, neg: 0, def: '可用时间远大于所需时间' },
      ]
    },
    {
      code: 'STRESS', name: '压力/应激', levels: [
        { code: 'EXTREME', name: '极端压力', mult: { diagnosis: 5.0, action: 5.0 }, neg: 1, def: '威胁性应激条件，可能导致认知隧道效应' },
        { code: 'HIGH', name: '高压力', mult: { diagnosis: 2.0, action: 2.0 }, neg: 1, def: '显著超出正常工作负荷的压力' },
        { code: 'NOMINAL', name: '标称压力', mult: { diagnosis: 1.0, action: 1.0 }, neg: 0, def: '正常工作压力水平' },
      ]
    },
    {
      code: 'COMPLEXITY', name: '复杂度', levels: [
        { code: 'HIGH_COMPLEX', name: '高度复杂', mult: { diagnosis: 5.0, action: 5.0 }, neg: 1, def: '非常复杂的任务，多个交叉耦合的子系统' },
        { code: 'MOD_COMPLEX', name: '中等复杂', mult: { diagnosis: 2.0, action: 2.0 }, neg: 1, def: '中等复杂度，存在一些不确定因素' },
        { code: 'NOMINAL', name: '标称复杂度', mult: { diagnosis: 1.0, action: 1.0 }, neg: 0, def: '标准复杂度任务' },
        { code: 'OBVIOUS', name: '显而易见', mult: { diagnosis: 0.1, action: 0.1 }, neg: 0, def: '简单明了的诊断/操作' },
      ]
    },
    {
      code: 'TRAINING', name: '经验/培训', levels: [
        { code: 'LOW', name: '培训不足', mult: { diagnosis: 10.0, action: 10.0 }, neg: 1, def: '培训不足或缺乏相关经验' },
        { code: 'NOMINAL', name: '标称培训', mult: { diagnosis: 1.0, action: 1.0 }, neg: 0, def: '接受过标准培训和资质认证' },
        { code: 'HIGH', name: '培训充分', mult: { diagnosis: 0.5, action: 0.5 }, neg: 0, def: '广泛的培训和丰富的实践经验' },
      ]
    },
    {
      code: 'PROCEDURE', name: '规程/流程', levels: [
        { code: 'NOT_AVAIL', name: '无规程', mult: { diagnosis: 50.0, action: 50.0 }, neg: 1, def: '没有可用的规程指导' },
        { code: 'INCOMPLETE', name: '规程不完整', mult: { diagnosis: 20.0, action: 20.0 }, neg: 1, def: '规程存在但不完整或不准确' },
        { code: 'NOMINAL', name: '标称规程', mult: { diagnosis: 1.0, action: 1.0 }, neg: 0, def: '规程可用且基本适用' },
        { code: 'DIAG_PROC', name: '诊断型规程', mult: { diagnosis: 0.5, action: 0.5 }, neg: 0, def: '专门的诊断/症状导向型规程' },
      ]
    },
    {
      code: 'ERGONOMICS', name: '人机工程', levels: [
        { code: 'POOR', name: '人机界面差', mult: { diagnosis: 50.0, action: 50.0 }, neg: 1, def: '人机界面设计不良，缺少关键信息' },
        { code: 'BELOW', name: '低于标准', mult: { diagnosis: 10.0, action: 10.0 }, neg: 1, def: '人机界面部分不足' },
        { code: 'NOMINAL', name: '标称工程', mult: { diagnosis: 1.0, action: 1.0 }, neg: 0, def: '满足基本人因工程标准' },
        { code: 'GOOD', name: '良好设计', mult: { diagnosis: 0.5, action: 0.5 }, neg: 0, def: '符合人因工程最佳实践' },
      ]
    },
    {
      code: 'FITNESS', name: '适健状态', levels: [
        { code: 'UNFIT', name: '状态不佳', mult: { diagnosis: 1.0, action: 1.0 }, neg: 1, def: '操纵员身心状态不佳，P(failure)=1.0' },
        { code: 'DEGRADED', name: '降级状态', mult: { diagnosis: 5.0, action: 5.0 }, neg: 1, def: '疲劳或轻微健康问题' },
        { code: 'NOMINAL', name: '标称状态', mult: { diagnosis: 1.0, action: 1.0 }, neg: 0, def: '正常身心状态' },
      ]
    },
    {
      code: 'PROCESS', name: '工作流程', levels: [
        { code: 'POOR', name: '流程差', mult: { diagnosis: 2.0, action: 5.0 }, neg: 1, def: '缺乏有效的工作流程控制和沟通机制' },
        { code: 'NOMINAL', name: '标称流程', mult: { diagnosis: 1.0, action: 1.0 }, neg: 0, def: '标准的工作流程控制' },
        { code: 'GOOD', name: '良好流程', mult: { diagnosis: 0.5, action: 0.5 }, neg: 0, def: '严格的交叉核对和独立验证流程' },
      ]
    }
  ];

  const batch = db.transaction(() => {
    for (const mode of modes) {
      for (const tt of taskTypes) {
        for (const psf of psfDefs) {
          for (const lv of psf.levels) {
            ins.run(
              psf.code, psf.name, mode, tt,
              lv.code, lv.name, lv.mult[tt], lv.neg, lv.def
            );
          }
        }
      }
    }
  });
  batch();
});

// ─── Tag Dictionary ────────────────────────────────────────────────

seedIfEmpty('tag_dict', () => {
  const ins = db.prepare(`INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref) VALUES (?,?,?,?,?,?)`);
  const tags = [
    ['error_type', 'ET-001', '遗漏错误', 'omission', '操纵员未执行规定的操作步骤', 'NUREG/CR-6883'],
    ['error_type', 'ET-002', '误操作', 'commission', '操纵员执行了错误的操作', 'NUREG/CR-6883'],
    ['error_type', 'ET-003', '时序错误', 'timing', '操纵员在错误的时间执行操作', 'NUREG/CR-6883'],
    ['error_type', 'ET-004', '顺序错误', 'sequence', '操纵员执行操作的顺序有误', 'NUREG/CR-6883'],
    ['error_mode', 'EM-001', '感知失败', 'perception', '未能正确感知报警或指示信息', 'THERP'],
    ['error_mode', 'EM-002', '判断失误', 'judgment', '未能正确理解工况或做出决策', 'THERP'],
    ['error_mode', 'EM-003', '执行偏差', 'execution', '知道正确动作但执行中发生偏差', 'THERP'],
    ['error_mode', 'EM-004', '违章操作', 'violation', '故意偏离规程要求的操作', 'THERP'],
    ['psf_category', 'PSF-001', '组织因素', 'organizational', '管理和组织层面的影响因素', 'SPAR-H'],
    ['psf_category', 'PSF-002', '个人因素', 'individual', '操纵员个人能力和状态', 'SPAR-H'],
    ['psf_category', 'PSF-003', '任务因素', 'task', '任务自身特征和要求', 'SPAR-H'],
    ['psf_category', 'PSF-004', '环境因素', 'environment', '工作环境和人机界面', 'SPAR-H'],
    ['consequence', 'CQ-001', '安全相关', 'safety', '影响核安全的事件', 'HAF003'],
    ['consequence', 'CQ-002', '运行影响', 'operational', '影响机组运行但不直接影响核安全', 'HAF003'],
    ['consequence', 'CQ-003', '经济损失', 'economic', '造成经济损失但无安全影响', 'HAF003'],
  ];
  const batch = db.transaction(() => { tags.forEach(t => ins.run(...t)); });
  batch();
});

// ─── Admin User ────────────────────────────────────────────────────

seedIfEmpty('sys_user', () => {
  const hash = bcrypt.hashSync('admin123', 10);
  db.prepare(`INSERT INTO sys_user (username, password_hash, real_name, role) VALUES (?,?,?,?)`)
    .run('admin', hash, '系统管理员', 'admin');
  const hash2 = bcrypt.hashSync('analyst123', 10);
  db.prepare(`INSERT INTO sys_user (username, password_hash, real_name, role) VALUES (?,?,?,?)`)
    .run('zhangwei', hash2, '张伟', 'analyst');
});

// ─── Sample Events ─────────────────────────────────────────────────

seedIfEmpty('event_main', () => {
  const insEvent = db.prepare(`INSERT INTO event_main
    (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text)
    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`);

  const insTask = db.prepare(`INSERT INTO task_unit
    (event_id, task_code, task_name, task_type, task_stage, operation_object, procedure_ref, available_time, task_desc)
    VALUES (?,?,?,?,?,?,?,?,?)`);

  const insScenario = db.prepare(`INSERT INTO scenario_info
    (event_id, task_id, scenario_name, system_state, environmental_condition, interface_state, procedure_state, time_pressure_desc)
    VALUES (?,?,?,?,?,?,?,?)`);

  const insPerson = db.prepare(`INSERT INTO person_info
    (person_code, person_name, department, role_name, experience_years, qualification_level)
    VALUES (?,?,?,?,?,?)`);

  const insEP = db.prepare(`INSERT INTO event_person
    (event_id, person_id, involvement_type, responsibility_desc, behavior_note)
    VALUES (?,?,?,?,?)`);

  const insEvidence = db.prepare(`INSERT INTO evidence_chain
    (event_id, evidence_type, doc_code, doc_title, source_ref, page_tag, quote_note, version_no, operator_name, operate_time)
    VALUES (?,?,?,?,?,?,?,?,?,?)`);

  const insFactor = db.prepare(`INSERT INTO impact_factor
    (event_id, task_id, factor_category, factor_name, factor_level, factor_value, assessment_basis, data_source)
    VALUES (?,?,?,?,?,?,?,?)`);

  const insEventTag = db.prepare(`INSERT INTO event_tag
    (event_id, tag_id, review_status, created_at)
    VALUES (?,?,?,datetime('now'))`);

  const batch = db.transaction(() => {
    // ── Persons
    insPerson.run('P-001', '王建国', '运行处', '高级操纵员', 15, 'SRO');
    insPerson.run('P-002', '李明', '运行处', '操纵员', 8, 'RO');
    insPerson.run('P-003', '张丽华', '维修处', '仪控工程师', 12, '高级工程师');
    insPerson.run('P-004', '刘强', '运行处', '值长', 20, 'SS');
    insPerson.run('P-005', '陈晓峰', '安全处', '安全工程师', 10, '注册核安全工程师');

    // ── Event 1
    let eid = insEvent.run(
      'HF-2026-001', '1号机组主给水流量控制阀误动作事件',
      '设备故障', '人因事件', '操作失误',
      '2024-03-15 14:30:00', '大亚湾核电站', '1', '主给水系统',
      '满功率运行', '运行影响', '机组降功率至80%FP',
      '运行日志', '2024年3月15日14:30，1号机组满功率运行期间，操纵员在执行主给水流量调节时，误选控制回路导致主给水流量控制阀突然关小，蒸汽发生器水位快速下降。操纵员在30秒内识别异常并切换至手动控制，恢复给水流量。事件导致机组短暂降功率至80%FP。'
    ).lastInsertRowid;

    let tid = insTask.run(eid, 'T-001-01', '主给水流量控制回路切换', 'action', '操作阶段', '主给水流量控制阀', 'GOP-1-001 第5.3节', '60秒', '操纵员需在DCS上选择正确的控制回路并执行切换操作').lastInsertRowid;
    insScenario.run(eid, tid, '满功率给水调节场景', '反应堆满功率稳态运行', '主控室正常照明和温度', 'DCS操作画面-给水控制', '通用运行规程GOP-1-001', '中等时间压力，需在蒸汽发生器水位降至低限前完成');
    insEP.run(eid, 1, '直接责任人', '负责主给水控制操作', '在执行控制回路切换时选错控制对象');
    insEP.run(eid, 4, '监督责任人', '值长监督操作', '未及时发现操纵员选错控制回路');
    insEvidence.run(eid, '运行日志', 'DOC-2024-0315-01', '1号机组运行日志', '运行处档案', '第15页', '14:30主给水流量控制阀开度突降至30%', 'V1.0', '王建国', '2024-03-15');
    insFactor.run(eid, tid, '界面设计', '人机界面', '中等', 2.0, 'DCS画面上控制回路标识不够清晰', 'SPAR-H');
    insFactor.run(eid, tid, '培训', '经验培训', '标称', 1.0, '操纵员已接受标准培训', 'SPAR-H');
    insEventTag.run(eid, 2, 'approved');
    insEventTag.run(eid, 7, 'approved');

    // ── Event 2
    eid = insEvent.run(
      'HF-2026-002', '2号机组安全壳隔离阀未按时关闭事件',
      '人因失误', '人因事件', '遗漏错误',
      '2024-04-22 09:15:00', '秦山核电站', '2', '安全壳隔离系统',
      '冷停堆', '安全相关', '安全壳完整性短暂受损',
      '事件报告', '2024年4月22日09:15，2号机组冷停堆检修后恢复过程中，操纵员未按规程要求及时关闭安全壳隔离阀，导致安全壳完整性在约20分钟内处于受损状态。经值长提醒后立即执行关闭操作。'
    ).lastInsertRowid;

    tid = insTask.run(eid, 'T-002-01', '安全壳隔离阀关闭操作', 'action', '恢复阶段', '安全壳隔离阀EV-001', 'SOP-CT-003 第4.2节', '30分钟', '按规程要求在特定工况下关闭安全壳隔离阀').lastInsertRowid;
    insScenario.run(eid, tid, '冷停堆恢复场景', '反应堆冷停堆，正在恢复', '主控室正常', '安全壳状态监测画面', '停堆运行规程SOP-CT-003', '低时间压力但有明确的规程时间节点要求');
    insEP.run(eid, 2, '直接责任人', '负责安全壳隔离阀操作', '遗漏了规程中的操作步骤');
    insEvidence.run(eid, '事件报告', 'DOC-2024-0422-01', '2号机组安全壳隔离阀未关闭事件报告', '安全处', '全文', '操纵员在检查清单中遗漏第23项操作步骤', 'V1.0', '李明', '2024-04-22');
    insEventTag.run(eid, 1, 'approved');
    insEventTag.run(eid, 8, 'pending');

    // ── Event 3
    eid = insEvent.run(
      'HF-2026-003', '3号机组硼浓度调节超差事件',
      '操作偏差', '人因事件', '执行错误',
      '2024-05-08 22:45:00', '福清核电站', '3', '化学和容积控制系统',
      '功率运行', '运行影响', '硼浓度偏差已纠正，未影响反应性控制',
      '运行日志', '2024年5月8日22:45，3号机组夜班操纵员在执行硼浓度调节操作时，因计算稀释水量出现偏差，导致一回路硼浓度低于目标值约15ppm。操纵员通过硼化操作在45分钟内将硼浓度恢复至目标范围。'
    ).lastInsertRowid;

    tid = insTask.run(eid, 'T-003-01', '一回路硼浓度稀释操作', 'action', '操作阶段', '化学和容积控制系统CVCS', 'GOP-3-002 第6.1节', '120分钟', '根据目标硼浓度计算稀释水量并执行稀释操作').lastInsertRowid;
    insScenario.run(eid, tid, '夜班硼稀释调节场景', '反应堆功率运行', '夜间主控室，低照明模式', 'CVCS操作画面和硼浓度趋势', '硼调节操作规程', '低时间压力，但夜班疲劳因素需考虑');
    insFactor.run(eid, tid, '适健状态', '疲劳', '降级', 5.0, '夜班22:45发生，操纵员处于疲劳状态', 'SPAR-H');
    insFactor.run(eid, tid, '复杂度', '计算复杂度', '中等', 2.0, '硼浓度稀释量计算需要多步骤', 'SPAR-H');
    insEventTag.run(eid, 5, 'approved');
    insEventTag.run(eid, 9, 'approved');

    // ── Event 4
    eid = insEvent.run(
      'HF-2026-004', '1号机组柴油发电机组未能按时启动事件',
      '设备与人因', '人因事件', '维修不当',
      '2024-06-12 10:00:00', '田湾核电站', '1', '应急柴油发电机系统',
      '满功率运行', '安全相关', '备用柴油发电机不可用约4小时',
      '维修记录', '2024年6月12日定期试验中，1号应急柴油发电机启动失败。调查发现维修人员在上次定期维修中未正确复位燃油系统排气阀，导致燃油供给管路存气。事件导致该台柴油机不可用约4小时。'
    ).lastInsertRowid;

    tid = insTask.run(eid, 'T-004-01', '柴油发电机燃油系统维修后复位', 'action', '维修阶段', '柴油发电机燃油排气阀', 'MNT-DG-005 第3.4节', '不适用', '维修完成后按检查清单逐项复位设备状态').lastInsertRowid;
    insEP.run(eid, 3, '直接责任人', '负责柴油发电机维修', '未执行维修后检查清单中的排气阀复位步骤');
    insEvidence.run(eid, '维修记录', 'DOC-2024-0612-01', '1号柴油发电机定期维修记录', '维修处', '第8页', '维修后检查清单第12项"排气阀复位"未勾选', 'V1.0', '张丽华', '2024-06-12');
    insEventTag.run(eid, 1, 'approved');
    insEventTag.run(eid, 4, 'pending');

    // ── Event 5
    eid = insEvent.run(
      'HF-2026-005', '2号机组控制棒异常落棒事件',
      '操作失误', '人因事件', '操作失误',
      '2024-07-03 16:20:00', '红沿河核电站', '2', '控制棒驱动系统',
      '升功率', '安全相关', '机组自动停堆，安全停堆成功',
      '事件报告', '2024年7月3日16:20，2号机组升功率过程中，操纵员在调整控制棒位置时误触相邻控制棒组按钮，导致一组控制棒意外落棒，反应堆保护系统自动触发停堆。所有安全系统响应正常。'
    ).lastInsertRowid;

    tid = insTask.run(eid, 'T-005-01', '控制棒位置调整操作', 'diagnosis', '操作阶段', '控制棒驱动机构', 'GOP-2-001 第7.2节', '无硬性时间限制', '升功率过程中根据物理试验要求调整控制棒位置').lastInsertRowid;
    insScenario.run(eid, tid, '升功率控制棒调整场景', '反应堆升功率阶段', '主控室正常，多人在场', '控制棒位置显示画面', '升功率运行规程', '无明显时间压力，但操作需精确性');
    insEP.run(eid, 1, '直接责任人', '执行控制棒调整操作', '误触相邻控制棒组按钮');
    insFactor.run(eid, tid, '人机界面', '控制面板布局', '低于标准', 10.0, '控制棒操作按钮间距过小，相邻按钮容易误触', 'SPAR-H');
    insEventTag.run(eid, 2, 'approved');
    insEventTag.run(eid, 7, 'approved');

    // ── Event 6
    eid = insEvent.run(
      'HF-2026-006', '化学取样过程中放射性物质泄漏事件',
      '操作偏差', '人因事件', '违章操作',
      '2024-07-28 11:30:00', '宁德核电站', '1', '取样系统',
      '满功率运行', '运行影响', '局部区域放射性轻微超标，24小时内恢复',
      '事件报告', '2024年7月28日11:30，化学取样人员在执行一回路水样采集时未按规程佩戴全套防护装备，且在取样阀操作过程中因操作过快导致少量放射性水样溢出。事件造成取样间局部区域放射性轻微超标。'
    ).lastInsertRowid;

    insTask.run(eid, 'T-006-01', '一回路水样采集操作', 'action', '取样阶段', '一回路取样阀', 'CHP-SA-002 第2.3节', '30分钟', '按取样规程操作取样阀并收集水样');
    insEP.run(eid, 5, '分析责任人', '安全监督与事件分析', '事后开展事件分析和根本原因调查');
    insEventTag.run(eid, 6, 'approved');
    insEventTag.run(eid, 10, 'pending');

    // ── Event 7
    eid = insEvent.run(
      'HF-2026-007', '主控室火灾报警误判导致不当响应事件',
      '判断失误', '人因事件', '诊断错误',
      '2024-08-15 03:10:00', '阳江核电站', '3', '火灾探测与报警系统',
      '满功率运行', '运行影响', '不必要的设备隔离，影响约2小时',
      '运行日志', '2024年8月15日03:10，主控室接到非安全相关厂房火灾报警信号。夜班操纵员误判为真实火灾，未经充分确认即执行了火灾响应规程，对相关区域设备进行了不必要的隔离操作。后确认为探测器故障引起的误报警。'
    ).lastInsertRowid;

    tid = insTask.run(eid, 'T-007-01', '火灾报警信号诊断', 'diagnosis', '诊断阶段', '火灾报警面板', 'AOP-FIRE-001 第2.1节', '10分钟', '接到火灾报警后确认报警的真实性和具体位置').lastInsertRowid;
    insScenario.run(eid, tid, '夜间火灾报警诊断场景', '满功率运行，深夜值班', '夜间值班，人员较少', '火灾报警面板和区域监控', '火灾报警异常响应规程AOP-FIRE-001', '高时间压力，需要快速判断');
    insFactor.run(eid, tid, '压力应激', '时间压力', '高', 2.0, '火灾报警要求快速响应', 'SPAR-H');
    insFactor.run(eid, tid, '适健状态', '疲劳', '降级', 5.0, '凌晨3:10发生，深夜值班疲劳', 'SPAR-H');
    insEventTag.run(eid, 9, 'approved');
    insEventTag.run(eid, 3, 'approved');

    // ── Event 8
    eid = insEvent.run(
      'HF-2026-008', '废液排放过程中放射性浓度监测超标事件',
      '监督失误', '人因事件', '遗漏错误',
      '2024-09-05 14:00:00', '台山核电站', '1', '废液处理系统',
      '满功率运行', '安全相关', '废液排放暂停，环境未受影响',
      '事件报告', '2024年9月5日14:00，在执行低放废液排放过程中，监督人员未按规程要求在排放前确认在线辐射监测仪的校准状态，导致使用偏差较大的监测数据进行排放决策。排放开始后30分钟独立监测发现放射性浓度高于预期，立即停止排放。'
    ).lastInsertRowid;

    insTask.run(eid, 'T-008-01', '废液排放前辐射监测确认', 'action', '准备阶段', '在线辐射监测仪', 'WMP-LR-001 第3.1节', '60分钟', '排放前确认监测仪器校准状态并核对监测数据');
    insEventTag.run(eid, 1, 'pending');
    insEventTag.run(eid, 11, 'approved');

    // ── Event 9
    eid = insEvent.run(
      'HF-2026-009', '换料操作中燃料组件碰擦事件',
      '操作偏差', '人因事件', '执行错误',
      '2024-10-18 08:30:00', '昌江核电站', '1', '燃料装卸系统',
      '换料停堆', '安全相关', '燃料组件轻微表面损伤，经检查可继续使用',
      '运行日志', '2024年10月18日08:30，1号机组换料操作过程中，燃料操作员在使用燃料转运装置移动燃料组件时，因定位操作不精确导致燃料组件与相邻组件发生轻微碰擦。经水下摄像检查确认仅为表面轻微擦痕。'
    ).lastInsertRowid;

    tid = insTask.run(eid, 'T-009-01', '燃料组件转运定位操作', 'action', '换料阶段', '燃料转运装置', 'FHP-TR-001 第5.6节', '不适用', '使用燃料转运装置精确定位和移动燃料组件').lastInsertRowid;
    insFactor.run(eid, tid, '人机界面', '定位系统精度', '低于标准', 10.0, '燃料转运装置定位辅助系统需要升级', 'SPAR-H');
    insEventTag.run(eid, 5, 'approved');
    insEventTag.run(eid, 12, 'approved');

    // ── Event 10
    eid = insEvent.run(
      'HF-2026-010', '安全注入系统定期试验中阀门操作顺序错误事件',
      '操作失误', '人因事件', '顺序错误',
      '2024-11-22 10:15:00', '防城港核电站', '2', '安全注入系统',
      '满功率运行', '运行影响', '试验中断并重新执行，未影响系统可用性',
      '试验记录', '2024年11月22日10:15，在执行安全注入系统定期试验时，操纵员未按试验规程规定的阀门操作顺序执行，先开启了下游阀门后才开启上游隔离阀，导致系统压力瞬态。试验立即中断，系统恢复后重新按正确顺序执行试验。'
    ).lastInsertRowid;

    tid = insTask.run(eid, 'T-010-01', '安注系统定期试验阀门操作', 'action', '试验阶段', '安全注入系统阀门', 'STP-SI-012 第4.3节', '120分钟', '按试验规程规定顺序操作安注系统相关阀门').lastInsertRowid;
    insScenario.run(eid, tid, '安注系统定期试验场景', '满功率运行，定期试验', '主控室和就地同步操作', '安注系统操作画面', '安注系统定期试验规程STP-SI-012', '低时间压力但要求操作顺序严格正确');
    insFactor.run(eid, tid, '规程', '规程表述', '中等', 2.0, '试验规程中阀门操作顺序标注不够醒目', 'SPAR-H');
    insEventTag.run(eid, 3, 'approved');
    insEventTag.run(eid, 8, 'approved');

    // ── Sample Analysis Case
    const caseId = db.prepare(`INSERT INTO analysis_case
      (case_code, method_code, source_event_id, source_task_id, analysis_path, case_name, analyst, review_status, summary)
      VALUES (?,?,?,?,?,?,?,?,?)`)
      .run('CASE-2024-001', 'SPAR-H', 1, 1, 'SPAR-H标准路径', '主给水流量控制阀误动作SPAR-H分析', '陈晓峰', 'completed',
        '对1号机组主给水流量控制阀误动作事件进行SPAR-H方法人因可靠性分析').lastInsertRowid;

    const ctDiag = db.prepare(`INSERT INTO case_task (case_id, task_type, nominal_hep, composite_psf, raw_hep, adjusted_hep, negative_count, final_hep, calc_note)
      VALUES (?,?,?,?,?,?,?,?,?)`)
      .run(caseId, 'diagnosis', 0.01, 2.0, 0.02, 0.02, 0, 0.02, 'SPAR-H诊断任务标称HEP=1E-2').lastInsertRowid;

    const ctAct = db.prepare(`INSERT INTO case_task (case_id, task_type, nominal_hep, composite_psf, raw_hep, adjusted_hep, negative_count, final_hep, calc_note)
      VALUES (?,?,?,?,?,?,?,?,?)`)
      .run(caseId, 'action', 0.001, 2.0, 0.002, 0.002, 0, 0.002, 'SPAR-H操作任务标称HEP=1E-3').lastInsertRowid;

    const insPSF = db.prepare(`INSERT INTO case_psf_value (case_task_id, psf_code, psf_name, level_code, level_name, multiplier, is_negative, basis_text) VALUES (?,?,?,?,?,?,?,?)`);
    insPSF.run(ctDiag, 'TIME', '可用时间', 'NOMINAL', '标称时间', 1.0, 0, '操纵员有足够的诊断时间');
    insPSF.run(ctDiag, 'STRESS', '压力/应激', 'NOMINAL', '标称压力', 1.0, 0, '正常工况压力');
    insPSF.run(ctDiag, 'COMPLEXITY', '复杂度', 'MOD_COMPLEX', '中等复杂', 2.0, 1, 'DCS画面控制回路标识不清增加复杂度');
    insPSF.run(ctDiag, 'TRAINING', '经验/培训', 'NOMINAL', '标称培训', 1.0, 0, '操纵员已完成培训');
    insPSF.run(ctDiag, 'PROCEDURE', '规程/流程', 'NOMINAL', '标称规程', 1.0, 0, '有可用规程');
    insPSF.run(ctDiag, 'ERGONOMICS', '人机工程', 'BELOW', '低于标准', 10.0, 1, 'DCS画面布局不佳');
    insPSF.run(ctDiag, 'FITNESS', '适健状态', 'NOMINAL', '标称状态', 1.0, 0, '操纵员状态正常');
    insPSF.run(ctDiag, 'PROCESS', '工作流程', 'NOMINAL', '标称流程', 1.0, 0, '标准工作流程');

    insPSF.run(ctAct, 'TIME', '可用时间', 'EXTRA', '额外时间', 0.1, 0, '有足够的操作时间');
    insPSF.run(ctAct, 'STRESS', '压力/应激', 'HIGH', '高压力', 2.0, 1, '给水流量异常增加操作压力');
    insPSF.run(ctAct, 'COMPLEXITY', '复杂度', 'NOMINAL', '标称复杂度', 1.0, 0, '切换操作本身不复杂');
    insPSF.run(ctAct, 'TRAINING', '经验/培训', 'NOMINAL', '标称培训', 1.0, 0, '操纵员已接受相关培训');
    insPSF.run(ctAct, 'PROCEDURE', '规程/流程', 'NOMINAL', '标称规程', 1.0, 0, '有操作规程可用');
    insPSF.run(ctAct, 'ERGONOMICS', '人机工程', 'BELOW', '低于标准', 10.0, 1, '控制界面标识不清');
    insPSF.run(ctAct, 'FITNESS', '适健状态', 'NOMINAL', '标称状态', 1.0, 0, '操纵员身心状态正常');
    insPSF.run(ctAct, 'PROCESS', '工作流程', 'NOMINAL', '标称流程', 1.0, 0, '标准流程控制');

    db.prepare(`INSERT INTO dependency_assessment
      (case_id, from_task_id, to_task_id, dependency_level, same_crew_flag, close_in_time_flag, same_location_flag, same_cues_flag, correction_value, basis_text)
      VALUES (?,?,?,?,?,?,?,?,?,?)`)
      .run(caseId, ctDiag, ctAct, 'moderate', 1, 1, 1, 1, 0.15, '同一操纵员在诊断后立即执行操作任务，中等依赖性');

    db.prepare(`INSERT INTO evidence_index
      (case_id, case_task_id, trace_step, source_table, source_pk, evidence_excerpt, recorder)
      VALUES (?,?,?,?,?,?,?)`)
      .run(caseId, ctDiag, 1, 'evidence_chain', 1, '14:30主给水流量控制阀开度突降至30%', '陈晓峰');
  });
  batch();
});

export default db;
