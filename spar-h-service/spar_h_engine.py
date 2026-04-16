"""
SPAR-H 人因可靠性分析计算引擎

基于 NUREG/CR-6883 标准化工厂分析风险人因可靠性分析方法(SPAR-H)
用于核电厂人因事件概率(HEP)的量化计算
"""

import math
from scipy import stats


# ============================================================
# 名义人因差错概率 (Nominal HEP)
# ============================================================
# 诊断任务和行动任务的基准 HEP 值
NOMINAL_HEP = {
    "diagnosis": 1e-2,
    "action": 1e-3,
}


# ============================================================
# CNI 先验分布 alpha 查找表
# 根据 mean_hep 的近似范围映射到 Beta 分布的 alpha 参数
# ============================================================
CNI_ALPHA_TABLE = [
    (1e-5, 0.01),
    (1e-4, 0.015),
    (1e-3, 0.11),
    (1e-2, 1.0),
    (5e-2, 2.0),
    (0.1,  3.0),
    (0.5,  5.0),
    (1.0,  10.0),
]


def _lookup_cni_alpha(mean_hep):
    """根据 mean_hep 在 CNI 查找表中进行对数空间插值，获取 alpha 参数"""
    if mean_hep <= 0:
        return CNI_ALPHA_TABLE[0][1]
    if mean_hep >= 1.0:
        return CNI_ALPHA_TABLE[-1][1]

    # 找到最接近的两个边界进行对数插值
    for i in range(len(CNI_ALPHA_TABLE) - 1):
        hep_low, alpha_low = CNI_ALPHA_TABLE[i]
        hep_high, alpha_high = CNI_ALPHA_TABLE[i + 1]
        if hep_low <= mean_hep <= hep_high:
            log_ratio = math.log10(mean_hep / hep_low) / math.log10(hep_high / hep_low)
            return alpha_low + log_ratio * (alpha_high - alpha_low)

    return CNI_ALPHA_TABLE[-1][1]


# ============================================================
# 核心计算函数
# ============================================================

def calculate_hep(nominal_hep, psf_multipliers):
    """
    计算人因差错概率 (HEP)

    参数:
        nominal_hep: 名义 HEP（诊断 0.01，行动 0.001）
        psf_multipliers: PSF 乘子列表，每项为 {multiplier, is_negative}
            - multiplier: 绩效影响因子的乘数值
            - is_negative: 是否为负面影响（乘子 > 1 即为负面）

    返回:
        包含复合 PSF、原始 HEP、调整后 HEP 等的字典

    计算逻辑:
        当负面 PSF 数量 >= 3 时，使用调整公式防止 HEP 超过 1.0
        调整公式: HEP = (nominal * composite) / (nominal * (composite - 1) + 1)
    """
    if not psf_multipliers:
        return {
            "composite_psf": 1.0,
            "raw_hep": nominal_hep,
            "negative_count": 0,
            "adjusted_hep": nominal_hep,
            "final_hep": nominal_hep,
        }

    composite_psf = 1.0
    negative_count = 0

    for psf in psf_multipliers:
        multiplier = psf.get("multiplier", 1.0)
        composite_psf *= multiplier
        if psf.get("is_negative", False):
            negative_count += 1

    raw_hep = nominal_hep * composite_psf

    # 当有 3 个及以上负面 PSF 时，使用调整公式
    if negative_count >= 3:
        denominator = nominal_hep * (composite_psf - 1) + 1
        adjusted_hep = (nominal_hep * composite_psf) / denominator if denominator != 0 else raw_hep
    else:
        adjusted_hep = raw_hep

    final_hep = min(adjusted_hep, 1.0)

    return {
        "composite_psf": round(composite_psf, 6),
        "raw_hep": round(raw_hep, 8),
        "negative_count": negative_count,
        "adjusted_hep": round(adjusted_hep, 8),
        "final_hep": round(final_hep, 8),
    }


def calculate_joint_hep(diagnosis_hep, action_hep):
    """
    计算联合人因差错概率

    对于诊断+行动的组合任务，联合概率为:
        P = 1 - (1 - P_diag)(1 - P_act)
    当概率值较小时近似为:
        P ≈ P_diag + P_act

    参数:
        diagnosis_hep: 诊断任务 HEP
        action_hep: 行动任务 HEP

    返回:
        包含精确值和近似值的字典
    """
    exact = 1.0 - (1.0 - diagnosis_hep) * (1.0 - action_hep)
    approximate = diagnosis_hep + action_hep

    return {
        "diagnosis_hep": round(diagnosis_hep, 8),
        "action_hep": round(action_hep, 8),
        "joint_hep_exact": round(exact, 8),
        "joint_hep_approximate": round(approximate, 8),
        "final_joint_hep": round(min(exact, 1.0), 8),
    }


def calculate_dependency(hep, dependency_level):
    """
    依赖性修正计算

    SPAR-H 方法定义了五级依赖性水平:
        - complete (完全依赖): HEP = 1.0
        - high (高度依赖):    HEP = (1 + HEP) / 2
        - moderate (中度依赖): HEP = (1 + 6*HEP) / 7
        - low (低度依赖):     HEP = (1 + 19*HEP) / 20
        - zero (零依赖):      HEP 不变

    参数:
        hep: 原始 HEP 值
        dependency_level: 依赖性等级字符串

    返回:
        包含修正前后 HEP 值的字典
    """
    level = dependency_level.lower().strip()
    formulas = {
        "complete": lambda h: 1.0,
        "high": lambda h: (1.0 + h) / 2.0,
        "moderate": lambda h: (1.0 + 6.0 * h) / 7.0,
        "low": lambda h: (1.0 + 19.0 * h) / 20.0,
        "zero": lambda h: h,
    }

    if level not in formulas:
        raise ValueError(f"未知的依赖性等级: {dependency_level}，有效值为: {list(formulas.keys())}")

    corrected_hep = formulas[level](hep)

    return {
        "original_hep": round(hep, 8),
        "dependency_level": level,
        "corrected_hep": round(corrected_hep, 8),
    }


def calculate_uncertainty(mean_hep):
    """
    不确定性分析 — 基于 Beta 分布

    使用 CNI (Constrained Non-Informative) 先验方法:
        1. 根据 mean_hep 查表获取 alpha 参数
        2. 由 mean = alpha / (alpha + beta) 推导 beta = alpha * (1 - mean) / mean
        3. 使用 scipy.stats.beta 计算分位数

    参数:
        mean_hep: 平均人因差错概率

    返回:
        包含分布参数和分位数 (p05, p50, p95) 的字典
    """
    mean_hep = max(min(mean_hep, 0.9999), 1e-8)

    alpha = _lookup_cni_alpha(mean_hep)
    beta_param = alpha * (1.0 - mean_hep) / mean_hep

    dist = stats.beta(alpha, beta_param)

    p05 = float(dist.ppf(0.05))
    p50 = float(dist.ppf(0.50))
    p95 = float(dist.ppf(0.95))

    return {
        "dist_type": "beta",
        "alpha": round(alpha, 6),
        "beta": round(beta_param, 6),
        "mean_hep": round(mean_hep, 8),
        "median_hep": round(p50, 8),
        "p05": round(p05, 8),
        "p50": round(p50, 8),
        "p95": round(p95, 8),
    }
