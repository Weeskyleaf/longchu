-- ============================================================
-- SPAR-H PSF 字典数据（满功率工况）
-- ============================================================

-- 时间 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_INSUFF', '时间不足够', 1.000000, 1, 'P(failure)=1.0，直接判定失败', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_BARELY', '时间刚好够(<20min)', 10.000000, 1, '可用时间少于20分钟', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_NOMINAL', '通常时间(30min)', 1.000000, 0, '通常时间约30分钟', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_EXTRA', '充足的时间(>60min)', 0.100000, 0, '充足的时间大于60分钟', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'diagnosis', 'TIME_VAST', '很多时间(>24h)', 0.010000, 0, '大量可用时间超过24小时', 'NUREG/CR-6883');

-- 时间 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'action', 'TIME_INSUFF', '时间不足够', 1.000000, 1, 'P(failure)=1.0', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'action', 'TIME_BARELY', '可用时间=所需时间', 10.000000, 1, '可用时间刚好等于所需时间', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'action', 'TIME_NOMINAL', '通常时间', 1.000000, 0, '通常时间', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'action', 'TIME_EXTRA', '充足的时间(≥5倍所需)', 0.100000, 0, '充足的时间', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TIME', '可用时间', 'full_power', 'action', 'TIME_VAST', '很多时间(≥50倍所需)', 0.010000, 0, '大量可用时间', 'NUREG/CR-6883');

-- 压力 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('STRESS', '压力', 'full_power', 'diagnosis', 'STRESS_HIGH2', '很高', 5.000000, 1, '很高的压力水平', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('STRESS', '压力', 'full_power', 'diagnosis', 'STRESS_HIGH', '高', 2.000000, 1, '高压力水平', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('STRESS', '压力', 'full_power', 'diagnosis', 'STRESS_NOMINAL', '正常', 1.000000, 0, '正常压力水平', 'NUREG/CR-6883');

-- 压力 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('STRESS', '压力', 'full_power', 'action', 'STRESS_HIGH2', '很高', 5.000000, 1, '很高的压力水平', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('STRESS', '压力', 'full_power', 'action', 'STRESS_HIGH', '高', 2.000000, 1, '高压力水平', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('STRESS', '压力', 'full_power', 'action', 'STRESS_NOMINAL', '正常', 1.000000, 0, '正常压力水平', 'NUREG/CR-6883');

-- 复杂度 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('COMPLEXITY', '复杂度', 'full_power', 'diagnosis', 'CMPLX_HIGH', '高度复杂', 5.000000, 1, '高度复杂的任务', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('COMPLEXITY', '复杂度', 'full_power', 'diagnosis', 'CMPLX_MED', '中等复杂', 2.000000, 1, '中等复杂度', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('COMPLEXITY', '复杂度', 'full_power', 'diagnosis', 'CMPLX_NOMINAL', '正常', 1.000000, 0, '正常复杂度', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('COMPLEXITY', '复杂度', 'full_power', 'diagnosis', 'CMPLX_EASY', '很容易诊断', 0.100000, 0, '非常容易诊断', 'NUREG/CR-6883');

-- 复杂度 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('COMPLEXITY', '复杂度', 'full_power', 'action', 'CMPLX_HIGH', '高度复杂', 5.000000, 1, '高度复杂的任务', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('COMPLEXITY', '复杂度', 'full_power', 'action', 'CMPLX_MED', '中等复杂', 2.000000, 1, '中等复杂度', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('COMPLEXITY', '复杂度', 'full_power', 'action', 'CMPLX_NOMINAL', '正常', 1.000000, 0, '正常复杂度', 'NUREG/CR-6883');

-- 经验/培训 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TRAINING', '经验/培训', 'full_power', 'diagnosis', 'TRAIN_LOW', '低', 10.000000, 1, '经验/培训不足', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TRAINING', '经验/培训', 'full_power', 'diagnosis', 'TRAIN_NOMINAL', '正常', 1.000000, 0, '正常培训水平', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TRAINING', '经验/培训', 'full_power', 'diagnosis', 'TRAIN_HIGH', '高', 0.500000, 0, '高水平培训', 'NUREG/CR-6883');

-- 经验/培训 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TRAINING', '经验/培训', 'full_power', 'action', 'TRAIN_LOW', '低', 3.000000, 1, '经验/培训不足', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TRAINING', '经验/培训', 'full_power', 'action', 'TRAIN_NOMINAL', '正常', 1.000000, 0, '正常培训水平', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('TRAINING', '经验/培训', 'full_power', 'action', 'TRAIN_HIGH', '高', 0.500000, 0, '高水平培训', 'NUREG/CR-6883');

-- 规程 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_NONE', '无', 50.000000, 1, '没有可用规程', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_INCOMPLETE', '有，但不完整', 20.000000, 1, '规程不完整', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_POOR', '有，但较差', 5.000000, 1, '规程质量较差', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_NOMINAL', '一般', 1.000000, 0, '一般规程', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'diagnosis', 'PROC_SYMPTOM', '征兆导向规程', 0.500000, 0, '征兆导向规程', 'NUREG/CR-6883');

-- 规程 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'action', 'PROC_NONE', '无', 50.000000, 1, '没有可用规程', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'action', 'PROC_INCOMPLETE', '有，但不完整', 20.000000, 1, '规程不完整', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'action', 'PROC_POOR', '有，但较差', 5.000000, 1, '规程质量较差', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCEDURE', '规程', 'full_power', 'action', 'PROC_NOMINAL', '一般', 1.000000, 0, '一般规程', 'NUREG/CR-6883');

-- 工效学/人机界面 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'diagnosis', 'ERGO_MISSING', '缺失/误导', 50.000000, 1, '人机界面信息缺失或误导', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'diagnosis', 'ERGO_POOR', '差', 10.000000, 1, '人机界面质量差', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'diagnosis', 'ERGO_NOMINAL', '一般', 1.000000, 0, '一般人机界面', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'diagnosis', 'ERGO_GOOD', '好', 0.500000, 0, '良好的人机界面', 'NUREG/CR-6883');

-- 工效学/人机界面 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'action', 'ERGO_MISSING', '缺失/误导', 50.000000, 1, '人机界面信息缺失或误导', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'action', 'ERGO_POOR', '差', 10.000000, 1, '人机界面质量差', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'action', 'ERGO_NOMINAL', '一般', 1.000000, 0, '一般人机界面', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('ERGONOMICS', '工效学/人机界面', 'full_power', 'action', 'ERGO_GOOD', '好', 0.500000, 0, '良好的人机界面', 'NUREG/CR-6883');

-- 职责适宜 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('FITNESS', '职责适宜', 'full_power', 'diagnosis', 'FIT_UNFIT', '不适宜', 1.000000, 1, 'P(failure)=1.0，直接判定失败', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('FITNESS', '职责适宜', 'full_power', 'diagnosis', 'FIT_DEGRADED', '不太适宜', 5.000000, 1, '身体或精神状态不太适宜', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('FITNESS', '职责适宜', 'full_power', 'diagnosis', 'FIT_NOMINAL', '正常', 1.000000, 0, '正常适宜', 'NUREG/CR-6883');

-- 职责适宜 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('FITNESS', '职责适宜', 'full_power', 'action', 'FIT_UNFIT', '不适宜', 1.000000, 1, 'P(failure)=1.0', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('FITNESS', '职责适宜', 'full_power', 'action', 'FIT_DEGRADED', '不太适宜', 5.000000, 1, '身体或精神状态不太适宜', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('FITNESS', '职责适宜', 'full_power', 'action', 'FIT_NOMINAL', '正常', 1.000000, 0, '正常适宜', 'NUREG/CR-6883');

-- 工序 PSF - 诊断
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCESS', '工序', 'full_power', 'diagnosis', 'WP_POOR', '差', 5.000000, 1, '工序组织差', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCESS', '工序', 'full_power', 'diagnosis', 'WP_NOMINAL', '一般', 1.000000, 0, '一般工序', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCESS', '工序', 'full_power', 'diagnosis', 'WP_GOOD', '好', 0.800000, 0, '良好的工序', 'NUREG/CR-6883');

-- 工序 PSF - 动作
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCESS', '工序', 'full_power', 'action', 'WP_POOR', '差', 5.000000, 1, '工序组织差', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCESS', '工序', 'full_power', 'action', 'WP_NOMINAL', '一般', 1.000000, 0, '一般工序', 'NUREG/CR-6883');
INSERT INTO sparh_psf_dict (psf_code, psf_name, plant_mode, task_type, level_code, level_name, multiplier, is_negative, definition_text, source_ref) VALUES
('PROCESS', '工序', 'full_power', 'action', 'WP_GOOD', '好', 0.500000, 0, '良好的工序', 'NUREG/CR-6883');

-- ============================================================
-- 标签字典数据
-- ============================================================
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('error_type', 'ET001', '遗漏型失误', '遗漏', '本该完成的任务或步骤被遗漏', 'Swain分类', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('error_type', 'ET002', '执行型失误-选择', '选择错误', '选择了错误的控制', 'Swain分类', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('error_type', 'ET003', '执行型失误-序列', '序列错误', '操作顺序错误', 'Swain分类', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('error_type', 'ET004', '执行型失误-时间', '时间错误', '操作时间不当', 'Swain分类', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('error_type', 'ET005', '执行型失误-质量', '质量错误', '操作质量不达标', 'Swain分类', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('error_type', 'ET006', '无关失误', '无关行为', '执行了与任务无关的行为', 'Swain分类', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('cognitive_type', 'CT001', '技能型疏忽', '疏忽', '技能层面的疏忽和遗忘', 'Reason-SRK', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('cognitive_type', 'CT002', '规则型错误', '规则错误', '规则层面的错误', 'Reason-SRK', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('cognitive_type', 'CT003', '知识型错误', '知识错误', '知识层面的错误', 'Reason-SRK', 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('task_stage', 'TS001', '事故前', '事故前', '事故发生之前的阶段', NULL, 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('task_stage', 'TS002', '事故后', '事故后', '事故发生之后的阶段', NULL, 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('consequence', 'CL001', '严重', '严重', '造成重大影响', NULL, 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('consequence', 'CL002', '较重', '较重', '造成较大影响', NULL, 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('consequence', 'CL003', '一般', '一般', '造成一般影响', NULL, 1);
INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active) VALUES
('consequence', 'CL004', '轻微', '轻微', '造成轻微影响', NULL, 1);

-- ============================================================
-- 示例事件数据（10个核电站事件）
-- ============================================================
INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-001', '大亚湾核电站1号机组主泵跳闸误操作事件', '操作失误', '人因失误', '遗漏', '2024-01-15 08:30:00', '大亚湾核电站', '1号机组', '一回路冷却剂系统', '满功率运行', '一般', '机组降功率运行，无放射性泄漏', '运行日志', '2024年1月15日08:30，大亚湾核电站1号机组值班操纵员在执行主泵检修后恢复操作时，未按规程要求完成冷却剂系统阀门状态确认，直接启动主泵导致跳闸。操纵员工作经验5年，事发时为夜班交接班后2小时。事件导致机组降功率至70%运行约4小时，通过重新执行操作规程恢复正常。根本原因分析表明操纵员疲劳和规程执行不严格是主要人因。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-002', '秦山核电站3号机组安全壳隔离阀未关闭事件', '操作遗漏', '人因失误', '遗漏', '2024-02-20 14:15:00', '秦山核电站', '3号机组', '安全壳隔离系统', '换料大修', '较重', '安全壳完整性受到影响，启动应急响应', '事件报告', '2024年2月20日14:15，秦山核电站3号机组在换料大修期间，维修人员完成安全壳内设备维修后撤离时，遗漏关闭安全壳贯穿件隔离阀EBS-V003。该遗漏在次日巡检中被发现，此时安全壳已处于非隔离状态约18小时。调查发现维修工作票中缺少该阀门恢复检查项目，且交接班时未传递该信息。事件暴露了工作票管理和交接班流程的薄弱环节。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-003', '福清核电站5号机组化学与容积控制系统误配置事件', '操作失误', '人因失误', '选择错误', '2024-03-10 10:45:00', '福清核电站', '5号机组', '化学与容积控制系统', '满功率运行', '轻微', '硼浓度短暂偏离正常范围', '运行日志', '2024年3月10日10:45，福清核电站5号机组操纵员在进行硼浓度调整操作时，选择了错误的稀释流量设定值，导致一回路硼浓度下降速率超过技术规格书限值。辅助操纵员在约8分钟后发现异常并报告值长，立即终止稀释操作并启动硼化补偿。分析表明操纵员混淆了两个相似的操作界面参数，人机界面设计存在改进空间。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-004', '田湾核电站2号机组应急柴油发电机组定期试验操作序列错误', '操作失误', '人因失误', '序列错误', '2024-04-05 09:00:00', '田湾核电站', '2号机组', '应急电源系统', '满功率运行', '一般', '试验失败，柴油发电机重新测试合格', '试验报告', '2024年4月5日09:00，田湾核电站2号机组在执行应急柴油发电机组DG-B月度启动试验时，操纵员未按正确顺序执行预润滑和预热步骤，直接发出启动指令。柴油机虽然启动但因润滑不足出现异常振动，自动保护停机。经检查设备无损坏，重新按正确程序执行试验后合格。事件原因为新员工对试验规程理解不充分，且监护人未及时纠正。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-005', '红沿河核电站4号机组蒸汽发生器水位控制异常响应事件', '诊断延迟', '人因失误', '时间错误', '2024-05-18 16:30:00', '红沿河核电站', '4号机组', '二回路给水系统', '满功率运行', '较重', '蒸汽发生器水位低触发自动保护', '事件报告', '2024年5月18日16:30，红沿河核电站4号机组运行中蒸汽发生器SG-A水位出现异常波动，操纵员虽然观察到水位指示偏低但判断为仪表波动，未及时采取手动干预措施。约15分钟后水位持续下降触发低水位保护信号，自动安全系统启动辅助给水。事件分析表明操纵员对蒸汽发生器水位异常的诊断能力不足，未能区分仪表故障和实际工况变化，错过了最佳干预时间窗口。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-006', '宁德核电站1号机组电气开关误合闸事件', '操作失误', '人因失误', '选择错误', '2024-06-22 11:20:00', '宁德核电站', '1号机组', '厂用电系统', '停堆检修', '轻微', '电气短暂冲击，设备未损坏', '运行日志', '2024年6月22日11:20，宁德核电站1号机组停堆检修期间，电气维修人员在执行母线倒换操作时误合相邻开关柜断路器QF-205，导致两段母线短暂并联运行。保护系统在0.3秒内检测到异常并跳开相关断路器。事件原因为开关柜标识不清晰且维修人员未执行双人确认制度。现场改进措施包括重新标识所有开关柜并加装防误操作锁。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-007', '阳江核电站6号机组放射性废液排放超限事件', '监控疏忽', '人因失误', '遗漏', '2024-07-08 07:45:00', '阳江核电站', '6号机组', '废液处理系统', '满功率运行', '严重', '放射性废液排放超过日排放限值', '监管报告', '2024年7月8日07:45，阳江核电站6号机组废液处理系统运行人员在监控放射性废液排放过程中，未注意到在线辐射监测仪显示的排放浓度异常升高趋势。废液处理系统树脂床饱和导致净化效率下降，排放持续约3小时后被巡检人员发现。虽然排放浓度未超过安全限值，但累计排放量超过日排放技术规格书限值。事件暴露了废液排放监控流程的不足和运行人员对监测数据关注度不够。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-008', '台山核电站1号机组主控室火灾报警误判断处置事件', '诊断错误', '人因失误', '知识错误', '2024-08-12 03:15:00', '台山核电站', '1号机组', '消防系统', '满功率运行', '一般', '消防系统误动作，无实际火灾', '运行日志', '2024年8月12日03:15，台山核电站1号机组主控室接到电缆夹层区域火灾报警信号。夜班操纵员根据报警信息判断为火灾探测器故障误报警，仅记录报警信息未启动消防应急程序。30分钟后巡检人员到达现场发现电缆夹层存在轻微过热现象。虽然最终确认未发生明火，但操纵员的误判断延误了现场确认时间。分析表明夜班人员对火灾报警的响应策略存在偏差，培训中应加强对模糊信号的保守决策训练。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-009', '昌江核电站2号机组乏燃料水池冷却泵维修后恢复不完整事件', '维修失误', '人因失误', '质量错误', '2024-09-25 13:00:00', '昌江核电站', '2号机组', '乏燃料贮存冷却系统', '满功率运行', '较重', '冷却泵振动超标需重新维修', '维修记录', '2024年9月25日13:00，昌江核电站2号机组乏燃料水池冷却泵SFP-P01完成定期检修后启动运行，发现泵体振动值超过正常范围3倍。停泵检查发现维修人员在组装泵体时未正确安装密封环，且联轴器对中数据记录有误。调查表明维修班组同时处理多项工作任务，导致注意力分散，质量检查环节流于形式。事件导致冷却泵不可用时间延长48小时，期间依靠备用泵维持冷却。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('EVT-2024-010', '防城港核电站3号机组安注系统定期试验中通信失误事件', '沟通失误', '组织因素', '沟通不畅', '2024-10-30 15:00:00', '防城港核电站', '3号机组', '安全注入系统', '满功率运行', '一般', '试验中断，重新安排', '试验报告', '2024年10月30日15:00，防城港核电站3号机组在执行安全注入系统季度功能试验时，主控室操纵员与就地操作人员之间通信出现误解。操纵员指令关闭SIS-V015阀门，就地人员误操作了相邻的SIS-V016阀门。错误操作被主控室监控系统检测到并及时纠正，试验中断后重新执行。分析表明通信规程中对阀门标识的口头确认流程不够规范，且就地设备标牌字号过小不易辨识。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================
-- 默认管理员用户
-- ============================================================
INSERT INTO sys_user (username, password_hash, real_name, role, is_active, created_at) VALUES
('admin', 'admin123', '系统管理员', 'admin', 1, CURRENT_TIMESTAMP);
