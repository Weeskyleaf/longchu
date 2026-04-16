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
-- 示例事件数据（10个核电站人因事件）
-- ============================================================
INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-001', '大亚湾核电站1号机组主泵跳闸误操作事件', '操作失误', '人因失误', '遗漏', '2026-01-15 08:30:00', '大亚湾核电站', '1号机组', '一回路冷却剂系统', '满功率运行', '一般', '机组降功率运行，无放射性泄漏', '运行经验反馈报告', '2026年1月15日08:30，大亚湾核电站1号机组值班操纵员在执行主泵检修后恢复操作时，未按规程要求完成冷却剂系统阀门状态确认，直接启动主泵导致跳闸。操纵员工作经验5年，事发时为夜班交接班后2小时。事件导致机组降功率至70%运行约4小时，通过重新执行操作规程恢复正常。根本原因分析表明操纵员疲劳和规程执行不严格是主要人因。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-002', '秦山核电站3号机组安全壳隔离阀未关闭事件', '操作遗漏', '人因失误', '遗漏', '2026-02-20 14:15:00', '秦山核电站', '3号机组', '安全壳隔离系统', '换料大修', '较重', '安全壳完整性受到影响，启动应急响应', '事故调查报告', '2026年2月20日14:15，秦山核电站3号机组在换料大修期间，维修人员完成安全壳内设备维修后撤离时，遗漏关闭安全壳贯穿件隔离阀EBS-V003。该遗漏在次日巡检中被发现，此时安全壳已处于非隔离状态约18小时。调查发现维修工作票中缺少该阀门恢复检查项目，且交接班时未传递该信息。事件暴露了工作票管理和交接班流程的薄弱环节。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-003', '福清核电站5号机组化学与容积控制系统误配置事件', '操作失误', '人因失误', '选择错误', '2026-03-10 10:45:00', '福清核电站', '5号机组', '化学与容积控制系统', '满功率运行', '轻微', '硼浓度短暂偏离正常范围', '值班记录', '2026年3月10日10:45，福清核电站5号机组操纵员在进行硼浓度调整操作时，选择了错误的稀释流量设定值，导致一回路硼浓度下降速率超过技术规格书限值。辅助操纵员在约8分钟后发现异常并报告值长，立即终止稀释操作并启动硼化补偿。分析表明操纵员混淆了两个相似的操作界面参数，人机界面设计存在改进空间。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-004', '田湾核电站2号机组应急柴油发电机组定期试验操作序列错误', '操作失误', '人因失误', '序列错误', '2026-04-05 09:00:00', '田湾核电站', '2号机组', '应急电源系统', '满功率运行', '一般', '试验失败，柴油发电机重新测试合格', '模拟机试验', '2026年4月5日09:00，田湾核电站2号机组在执行应急柴油发电机组DG-B月度启动试验时，操纵员未按正确顺序执行预润滑和预热步骤，直接发出启动指令。柴油机虽然启动但因润滑不足出现异常振动，自动保护停机。经检查设备无损坏，重新按正确程序执行试验后合格。事件原因为新员工对试验规程理解不充分，且监护人未及时纠正。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-005', '红沿河核电站4号机组蒸汽发生器水位控制异常响应事件', '诊断延迟', '人因失误', '时间错误', '2026-05-18 16:30:00', '红沿河核电站', '4号机组', '二回路给水系统', '满功率运行', '较重', '蒸汽发生器水位低触发自动保护', '运行经验反馈报告', '2026年5月18日16:30，红沿河核电站4号机组运行中蒸汽发生器SG-A水位出现异常波动，操纵员虽然观察到水位指示偏低但判断为仪表波动，未及时采取手动干预措施。约15分钟后水位持续下降触发低水位保护信号，自动安全系统启动辅助给水。事件分析表明操纵员对蒸汽发生器水位异常的诊断能力不足，未能区分仪表故障和实际工况变化，错过了最佳干预时间窗口。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-006', '宁德核电站1号机组电气开关误合闸事件', '操作失误', '人因失误', '选择错误', '2026-06-22 11:20:00', '宁德核电站', '1号机组', '厂用电系统', '停堆检修', '轻微', '电气短暂冲击，设备未损坏', '值班记录', '2026年6月22日11:20，宁德核电站1号机组停堆检修期间，电气维修人员在执行母线倒换操作时误合相邻开关柜断路器QF-205，导致两段母线短暂并联运行。保护系统在0.3秒内检测到异常并跳开相关断路器。事件原因为开关柜标识不清晰且维修人员未执行双人确认制度。现场改进措施包括重新标识所有开关柜并加装防误操作锁。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-007', '阳江核电站6号机组放射性废液排放超限事件', '监控疏忽', '人因失误', '遗漏', '2026-07-08 07:45:00', '阳江核电站', '6号机组', '废液处理系统', '满功率运行', '严重', '放射性废液排放超过日排放限值', '事故调查报告', '2026年7月8日07:45，阳江核电站6号机组废液处理系统运行人员在监控放射性废液排放过程中，未注意到在线辐射监测仪显示的排放浓度异常升高趋势。废液处理系统树脂床饱和导致净化效率下降，排放持续约3小时后被巡检人员发现。虽然排放浓度未超过安全限值，但累计排放量超过日排放技术规格书限值。事件暴露了废液排放监控流程的不足和运行人员对监测数据关注度不够。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-008', '台山核电站1号机组主控室火灾报警误判断处置事件', '诊断错误', '人因失误', '知识错误', '2026-08-12 03:15:00', '台山核电站', '1号机组', '消防系统', '满功率运行', '一般', '消防系统误动作，无实际火灾', '专家判断', '2026年8月12日03:15，台山核电站1号机组主控室接到电缆夹层区域火灾报警信号。夜班操纵员根据报警信息判断为火灾探测器故障误报警，仅记录报警信息未启动消防应急程序。30分钟后巡检人员到达现场发现电缆夹层存在轻微过热现象。虽然最终确认未发生明火，但操纵员的误判断延误了现场确认时间。分析表明夜班人员对火灾报警的响应策略存在偏差，培训中应加强对模糊信号的保守决策训练。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-009', '昌江核电站2号机组乏燃料水池冷却泵维修后恢复不完整事件', '维修失误', '人因失误', '质量错误', '2026-09-25 13:00:00', '昌江核电站', '2号机组', '乏燃料贮存冷却系统', '满功率运行', '较重', '冷却泵振动超标需重新维修', '运行经验反馈报告', '2026年9月25日13:00，昌江核电站2号机组乏燃料水池冷却泵SFP-P01完成定期检修后启动运行，发现泵体振动值超过正常范围3倍。停泵检查发现维修人员在组装泵体时未正确安装密封环，且联轴器对中数据记录有误。调查表明维修班组同时处理多项工作任务，导致注意力分散，质量检查环节流于形式。事件导致冷却泵不可用时间延长48小时，期间依靠备用泵维持冷却。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO event_main (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text, created_at, updated_at) VALUES
('HF-2026-010', '防城港核电站3号机组安注系统定期试验中通信失误事件', '沟通失误', '组织因素', '沟通不畅', '2026-10-30 15:00:00', '防城港核电站', '3号机组', '安全注入系统', '满功率运行', '一般', '试验中断，重新安排', '模拟机试验', '2026年10月30日15:00，防城港核电站3号机组在执行安全注入系统季度功能试验时，主控室操纵员与就地操作人员之间通信出现误解。操纵员指令关闭SIS-V015阀门，就地人员误操作了相邻的SIS-V016阀门。错误操作被主控室监控系统检测到并及时纠正，试验中断后重新执行。分析表明通信规程中对阀门标识的口头确认流程不够规范，且就地设备标牌字号过小不易辨识。', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================
-- 影响因子数据（每个事件2-3条）
-- ============================================================

-- 事件1: 大亚湾主泵跳闸
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(1, '规程/操作规程', '操作规程完备性', '中', '2.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(1, '时间压力与认知裕度', '夜班交接班疲劳影响', '高', '5.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(1, '培训要求与满足度', '操纵员培训水平', '一般', '1.0');

-- 事件2: 秦山安全壳隔离阀
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(2, '规程/操作规程', '工作票管理规范性', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(2, '信息负荷/处理', '交接班信息传递完整性', '高', '5.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(2, '操作复杂度', '贯穿件阀门操作复杂度', '中', '2.0');

-- 事件3: 福清化容系统误配置
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(3, '人机界面设计', '操作界面参数辨识度', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(3, '操作复杂度', '硼浓度调整操作复杂度', '高', '5.0');

-- 事件4: 田湾柴油机试验序列错误
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(4, '培训要求与满足度', '新员工培训充分度', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(4, '规程/操作规程', '试验规程理解程度', '中', '2.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(4, '操作复杂度', '柴油机启动操作序列复杂度', '高', '5.0');

-- 事件5: 红沿河SG水位异常
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(5, '时间压力与认知裕度', '诊断响应时间窗口', '高', '5.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(5, '培训要求与满足度', '异常工况诊断培训', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(5, '信息负荷/处理', '仪表信息判断能力', '中', '2.0');

-- 事件6: 宁德电气开关误合闸
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(6, '人机界面设计', '开关柜标识清晰度', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(6, '规程/操作规程', '双人确认制度执行', '低', '10.0');

-- 事件7: 阳江废液排放超限
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(7, '信息负荷/处理', '监测数据关注度', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(7, '环境条件', '监控环境干扰因素', '中', '2.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(7, '时间压力与认知裕度', '长时间监控疲劳', '高', '5.0');

-- 事件8: 台山火灾报警误判断
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(8, '培训要求与满足度', '模糊信号保守决策培训', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(8, '时间压力与认知裕度', '夜班认知水平', '高', '5.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(8, '环境条件', '夜间值班环境影响', '中', '2.0');

-- 事件9: 昌江冷却泵维修
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(9, '操作复杂度', '泵体组装精度要求', '高', '5.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(9, '信息负荷/处理', '多任务并行信息处理', '高', '5.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(9, '培训要求与满足度', '维修技能培训水平', '中', '2.0');

-- 事件10: 防城港通信失误
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(10, '人机界面设计', '就地设备标牌辨识度', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(10, '规程/操作规程', '通信确认规程规范性', '低', '10.0');
INSERT INTO impact_factor (event_id, factor_category, factor_name, factor_level, factor_value) VALUES
(10, '环境条件', '就地操作环境条件', '一般', '1.0');

-- ============================================================
-- 事件标签关联数据（每个事件2-3条）
-- ============================================================

-- 事件1: 遗漏型失误(1) + 技能型疏忽(7) + 一般(14)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (1, 1, 'approved', '2026-01-16 10:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (1, 7, 'approved', '2026-01-16 10:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (1, 14, 'approved', '2026-01-16 10:00:00');

-- 事件2: 遗漏型失误(1) + 规则型错误(8) + 较重(13)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (2, 1, 'approved', '2026-02-21 09:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (2, 8, 'approved', '2026-02-21 09:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (2, 13, 'approved', '2026-02-21 09:00:00');

-- 事件3: 选择错误(2) + 知识型错误(9) + 轻微(15)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (3, 2, 'approved', '2026-03-11 14:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (3, 9, 'pending', '2026-03-11 14:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (3, 15, 'approved', '2026-03-11 14:00:00');

-- 事件4: 序列错误(3) + 规则型错误(8) + 一般(14)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (4, 3, 'approved', '2026-04-06 11:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (4, 8, 'approved', '2026-04-06 11:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (4, 14, 'approved', '2026-04-06 11:00:00');

-- 事件5: 时间错误(4) + 知识型错误(9) + 较重(13)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (5, 4, 'approved', '2026-05-19 08:30:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (5, 9, 'approved', '2026-05-19 08:30:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (5, 13, 'pending', '2026-05-19 08:30:00');

-- 事件6: 选择错误(2) + 技能型疏忽(7) + 轻微(15)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (6, 2, 'approved', '2026-06-23 10:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (6, 7, 'approved', '2026-06-23 10:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (6, 15, 'approved', '2026-06-23 10:00:00');

-- 事件7: 遗漏型失误(1) + 技能型疏忽(7) + 严重(12)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (7, 1, 'approved', '2026-07-09 09:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (7, 7, 'approved', '2026-07-09 09:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (7, 12, 'approved', '2026-07-09 09:00:00');

-- 事件8: 知识型错误(9) + 事故前(10) + 一般(14)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (8, 9, 'approved', '2026-08-13 10:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (8, 10, 'pending', '2026-08-13 10:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (8, 14, 'approved', '2026-08-13 10:00:00');

-- 事件9: 质量错误(5) + 规则型错误(8) + 较重(13)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (9, 5, 'approved', '2026-09-26 14:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (9, 8, 'approved', '2026-09-26 14:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (9, 13, 'approved', '2026-09-26 14:00:00');

-- 事件10: 序列错误(3) + 事故前(10) + 一般(14)
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (10, 3, 'approved', '2026-10-31 09:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (10, 10, 'approved', '2026-10-31 09:00:00');
INSERT INTO event_tag (event_id, tag_id, review_status, created_at) VALUES (10, 14, 'pending', '2026-10-31 09:00:00');

-- ============================================================
-- 证据链数据（每个事件1-2条）
-- ============================================================

-- 事件1
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(1, '运行经验反馈报告', '大亚湾1号机组主泵跳闸事件运行经验反馈报告', 'DYB-OEF-2026-001', '2026-01-16 10:00:00');
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(1, '值班记录', '2026年1月15日夜班值班记录', 'DYB-LOG-2026-0115', '2026-01-15 20:00:00');

-- 事件2
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(2, '事件报告', '秦山3号机组安全壳隔离阀未关闭事件调查报告', 'QS-ER-2026-002', '2026-02-22 09:00:00');
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(2, '值班记录', '2026年2月20日换料大修值班记录', 'QS-LOG-2026-0220', '2026-02-20 18:00:00');

-- 事件3
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(3, '值班记录', '福清5号机组2026年3月10日运行值班记录', 'FQ-LOG-2026-0310', '2026-03-10 12:00:00');

-- 事件4
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(4, '模拟机试验', '应急柴油发电机组启动操作模拟验证报告', 'TW-SIM-2026-004', '2026-04-08 14:00:00');
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(4, '事件报告', '田湾2号机组DG-B月度试验失败事件报告', 'TW-ER-2026-004', '2026-04-06 16:00:00');

-- 事件5
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(5, '运行经验反馈报告', '红沿河4号机组SG水位异常事件经验反馈', 'HYH-OEF-2026-005', '2026-05-20 10:00:00');
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(5, '事件报告', '蒸汽发生器水位控制异常响应事件调查报告', 'HYH-ER-2026-005', '2026-05-19 14:00:00');

-- 事件6
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(6, '值班记录', '宁德1号机组2026年6月22日检修值班记录', 'ND-LOG-2026-0622', '2026-06-22 16:00:00');

-- 事件7
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(7, '事件报告', '阳江6号机组废液排放超限事件调查报告', 'YJ-ER-2026-007', '2026-07-10 09:00:00');
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(7, '运行经验反馈报告', '放射性废液排放监控改进经验反馈', 'YJ-OEF-2026-007', '2026-07-15 10:00:00');

-- 事件8
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(8, '值班记录', '台山1号机组2026年8月12日夜班值班记录', 'TS-LOG-2026-0812', '2026-08-12 08:00:00');
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(8, '运行经验反馈报告', '火灾报警响应策略改进经验反馈报告', 'TS-OEF-2026-008', '2026-08-18 10:00:00');

-- 事件9
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(9, '运行经验反馈报告', '昌江2号机组冷却泵维修质量经验反馈', 'CJ-OEF-2026-009', '2026-09-28 10:00:00');
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(9, '值班记录', '昌江核电站2026年9月25日维修工作记录', 'CJ-MR-2026-0925', '2026-09-25 17:00:00');

-- 事件10
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(10, '模拟机试验', '安注系统通信流程模拟验证报告', 'FCG-SIM-2026-010', '2026-11-05 14:00:00');
INSERT INTO evidence_chain (event_id, evidence_type, doc_title, source_ref, operate_time) VALUES
(10, '事件报告', '防城港3号机组安注试验通信失误事件报告', 'FCG-ER-2026-010', '2026-10-31 16:00:00');

-- ============================================================
-- 默认管理员用户
-- ============================================================
INSERT INTO sys_user (username, password_hash, real_name, role, is_active, created_at) VALUES
('admin', 'admin123', '系统管理员', 'admin', 1, CURRENT_TIMESTAMP);
