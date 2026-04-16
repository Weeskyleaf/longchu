"""
SPAR-H 微服务 API 路由

提供人因可靠性分析的 RESTful 接口:
- 完整 SPAR-H 计算
- 单独 HEP 计算
- 依赖性修正
- 不确定性分析
- PSF 选项查询
"""

from flask import Blueprint, request, jsonify
from spar_h_engine import (
    NOMINAL_HEP,
    calculate_hep,
    calculate_joint_hep,
    calculate_dependency,
    calculate_uncertainty,
)

spar_h_bp = Blueprint("spar_h", __name__)


# ============================================================
# 8 项绩效影响因子 (PSF) 定义
# 包含诊断(diagnosis)和行动(action)两种任务类型的级别与乘子
# ============================================================
PSF_OPTIONS = [
    {
        "code": "available_time",
        "name": "可用时间",
        "name_en": "Available Time",
        "levels": {
            "diagnosis": [
                {"code": "inadequate",       "label": "时间不足",           "multiplier": None, "is_negative": True,  "note": "P(failure)=1.0"},
                {"code": "barely_adequate",   "label": "勉强足够(≈2/3所需时间)", "multiplier": 10,   "is_negative": True,  "note": ""},
                {"code": "nominal",           "label": "名义值(等于所需时间)",   "multiplier": 1,    "is_negative": False, "note": ""},
                {"code": "extra",             "label": "额外时间(1-2倍所需时间)", "multiplier": 0.1,  "is_negative": False, "note": ""},
                {"code": "expansive",         "label": "充裕时间(>2倍所需时间)",  "multiplier": 0.01, "is_negative": False, "note": ""},
            ],
            "action": [
                {"code": "inadequate",       "label": "时间不足",               "multiplier": None, "is_negative": True,  "note": "P(failure)=1.0"},
                {"code": "time_less_needed",  "label": "≈2/3所需时间",          "multiplier": 10,   "is_negative": True,  "note": ""},
                {"code": "nominal",           "label": "名义值",                "multiplier": 1,    "is_negative": False, "note": ""},
                {"code": "time_more_needed",  "label": "额外时间",              "multiplier": 0.1,  "is_negative": False, "note": ""},
                {"code": "expansive",         "label": "充裕时间(>5倍所需时间)", "multiplier": 0.01, "is_negative": False, "note": ""},
            ],
        },
    },
    {
        "code": "stress",
        "name": "压力/应激",
        "name_en": "Stress / Stressors",
        "levels": {
            "diagnosis": [
                {"code": "extreme",  "label": "极端压力",  "multiplier": 5,   "is_negative": True,  "note": ""},
                {"code": "high",     "label": "高压力",    "multiplier": 2,   "is_negative": True,  "note": ""},
                {"code": "nominal",  "label": "名义值",    "multiplier": 1,   "is_negative": False, "note": ""},
            ],
            "action": [
                {"code": "extreme",  "label": "极端压力",  "multiplier": 5,   "is_negative": True,  "note": ""},
                {"code": "high",     "label": "高压力",    "multiplier": 2,   "is_negative": True,  "note": ""},
                {"code": "nominal",  "label": "名义值",    "multiplier": 1,   "is_negative": False, "note": ""},
            ],
        },
    },
    {
        "code": "complexity",
        "name": "复杂性",
        "name_en": "Complexity",
        "levels": {
            "diagnosis": [
                {"code": "highly_complex", "label": "高度复杂",  "multiplier": 5,    "is_negative": True,  "note": ""},
                {"code": "moderately",     "label": "中度复杂",  "multiplier": 2,    "is_negative": True,  "note": ""},
                {"code": "nominal",        "label": "名义值",    "multiplier": 1,    "is_negative": False, "note": ""},
                {"code": "obvious",        "label": "明显诊断",  "multiplier": 0.1,  "is_negative": False, "note": ""},
            ],
            "action": [
                {"code": "highly_complex", "label": "高度复杂",  "multiplier": 5,    "is_negative": True,  "note": ""},
                {"code": "moderately",     "label": "中度复杂",  "multiplier": 2,    "is_negative": True,  "note": ""},
                {"code": "nominal",        "label": "名义值",    "multiplier": 1,    "is_negative": False, "note": ""},
            ],
        },
    },
    {
        "code": "experience",
        "name": "经验/培训",
        "name_en": "Experience / Training",
        "levels": {
            "diagnosis": [
                {"code": "low",     "label": "经验不足", "multiplier": 10,  "is_negative": True,  "note": ""},
                {"code": "nominal", "label": "名义值",   "multiplier": 1,   "is_negative": False, "note": ""},
                {"code": "high",    "label": "经验丰富", "multiplier": 0.5, "is_negative": False, "note": ""},
            ],
            "action": [
                {"code": "low",     "label": "经验不足", "multiplier": 3,   "is_negative": True,  "note": ""},
                {"code": "nominal", "label": "名义值",   "multiplier": 1,   "is_negative": False, "note": ""},
                {"code": "high",    "label": "经验丰富", "multiplier": 0.5, "is_negative": False, "note": ""},
            ],
        },
    },
    {
        "code": "procedures",
        "name": "规程",
        "name_en": "Procedures",
        "levels": {
            "diagnosis": [
                {"code": "not_available",  "label": "无规程",     "multiplier": 50,  "is_negative": True,  "note": ""},
                {"code": "incomplete",     "label": "规程不完整", "multiplier": 20,  "is_negative": True,  "note": ""},
                {"code": "available_poor", "label": "规程质量差", "multiplier": 5,   "is_negative": True,  "note": ""},
                {"code": "nominal",        "label": "名义值",     "multiplier": 1,   "is_negative": False, "note": ""},
            ],
            "action": [
                {"code": "not_available",  "label": "无规程",     "multiplier": 50,  "is_negative": True,  "note": ""},
                {"code": "incomplete",     "label": "规程不完整", "multiplier": 20,  "is_negative": True,  "note": ""},
                {"code": "available_poor", "label": "规程质量差", "multiplier": 5,   "is_negative": True,  "note": ""},
                {"code": "nominal",        "label": "名义值",     "multiplier": 1,   "is_negative": False, "note": ""},
            ],
        },
    },
    {
        "code": "ergonomics",
        "name": "人机工程/人机界面",
        "name_en": "Ergonomics / HMI",
        "levels": {
            "diagnosis": [
                {"code": "missing_misleading", "label": "缺失/误导", "multiplier": 50,  "is_negative": True,  "note": ""},
                {"code": "poor",               "label": "较差",      "multiplier": 10,  "is_negative": True,  "note": ""},
                {"code": "nominal",            "label": "名义值",    "multiplier": 1,   "is_negative": False, "note": ""},
                {"code": "good",               "label": "良好",      "multiplier": 0.5, "is_negative": False, "note": ""},
            ],
            "action": [
                {"code": "missing_misleading", "label": "缺失/误导", "multiplier": 50,  "is_negative": True,  "note": ""},
                {"code": "poor",               "label": "较差",      "multiplier": 10,  "is_negative": True,  "note": ""},
                {"code": "nominal",            "label": "名义值",    "multiplier": 1,   "is_negative": False, "note": ""},
                {"code": "good",               "label": "良好",      "multiplier": 0.5, "is_negative": False, "note": ""},
            ],
        },
    },
    {
        "code": "fitness",
        "name": "适合度",
        "name_en": "Fitness for Duty",
        "levels": {
            "diagnosis": [
                {"code": "unfit",   "label": "不适合", "multiplier": None, "is_negative": True,  "note": "P(failure)=1.0"},
                {"code": "degraded","label": "降级",   "multiplier": 5,    "is_negative": True,  "note": ""},
                {"code": "nominal", "label": "名义值", "multiplier": 1,    "is_negative": False, "note": ""},
            ],
            "action": [
                {"code": "unfit",   "label": "不适合", "multiplier": None, "is_negative": True,  "note": "P(failure)=1.0"},
                {"code": "degraded","label": "降级",   "multiplier": 5,    "is_negative": True,  "note": ""},
                {"code": "nominal", "label": "名义值", "multiplier": 1,    "is_negative": False, "note": ""},
            ],
        },
    },
    {
        "code": "work_process",
        "name": "工作流程",
        "name_en": "Work Processes",
        "levels": {
            "diagnosis": [
                {"code": "poor",    "label": "较差",   "multiplier": 2,   "is_negative": True,  "note": ""},
                {"code": "nominal", "label": "名义值", "multiplier": 1,   "is_negative": False, "note": ""},
                {"code": "good",    "label": "良好",   "multiplier": 0.8, "is_negative": False, "note": ""},
            ],
            "action": [
                {"code": "poor",    "label": "较差",   "multiplier": 5,   "is_negative": True,  "note": ""},
                {"code": "nominal", "label": "名义值", "multiplier": 1,   "is_negative": False, "note": ""},
                {"code": "good",    "label": "良好",   "multiplier": 0.5, "is_negative": False, "note": ""},
            ],
        },
    },
]


def _find_psf_multiplier(psf_code, level_code, task_type):
    """在 PSF 定义表中查找指定 PSF 级别的乘子值"""
    for psf in PSF_OPTIONS:
        if psf["code"] == psf_code:
            levels = psf["levels"].get(task_type, [])
            for lvl in levels:
                if lvl["code"] == level_code:
                    return lvl["multiplier"], lvl["is_negative"]
    return None, None


def _process_task(task):
    """
    处理单个任务（诊断或行动）的 HEP 计算

    解析 PSF 值，检查是否有导致 HEP=1.0 的极端 PSF，然后计算 HEP
    """
    task_type = task.get("task_type", "diagnosis")
    nominal = NOMINAL_HEP.get(task_type, 1e-2)
    psf_values = task.get("psf_values", [])

    psf_multipliers = []
    forced_failure = False

    for psf_val in psf_values:
        multiplier = psf_val.get("multiplier")
        is_negative = psf_val.get("is_negative", False)

        if multiplier is None:
            psf_code = psf_val.get("psf_code")
            level_code = psf_val.get("level_code")
            if psf_code and level_code:
                multiplier, is_negative = _find_psf_multiplier(psf_code, level_code, task_type)

        if multiplier is None:
            forced_failure = True
            continue

        psf_multipliers.append({
            "multiplier": multiplier,
            "is_negative": is_negative,
        })

    if forced_failure:
        return {
            "task_type": task_type,
            "nominal_hep": nominal,
            "forced_failure": True,
            "final_hep": 1.0,
            "note": "存在导致必然失败的 PSF 级别 (multiplier=null)",
        }

    result = calculate_hep(nominal, psf_multipliers)
    result["task_type"] = task_type
    result["nominal_hep"] = nominal
    result["forced_failure"] = False
    return result


# ============================================================
# API 路由
# ============================================================

@spar_h_bp.route("/api/spar-h/calculate", methods=["POST"])
def full_calculate():
    """
    完整 SPAR-H 计算接口

    输入 JSON:
    {
        "plant_mode": "power" | "shutdown",
        "tasks": [
            {
                "task_type": "diagnosis" | "action",
                "psf_values": [
                    {"psf_code": "...", "level_code": "...", "multiplier": ..., "is_negative": ...}
                ]
            }
        ],
        "dependency": {  // 可选
            "level": "zero" | "low" | "moderate" | "high" | "complete",
            "from_task": 0,
            "to_task": 1
        }
    }
    """
    try:
        data = request.get_json(force=True)
        if not data:
            return jsonify({"error": "请提供有效的 JSON 请求体"}), 400

        plant_mode = data.get("plant_mode", "power")
        tasks = data.get("tasks", [])

        if not tasks:
            return jsonify({"error": "至少需要一个任务 (tasks)"}), 400

        task_results = []
        for task in tasks:
            result = _process_task(task)
            task_results.append(result)

        response = {
            "plant_mode": plant_mode,
            "task_results": task_results,
        }

        # 如果有诊断+行动两个任务，计算联合 HEP
        diagnosis_results = [r for r in task_results if r.get("task_type") == "diagnosis"]
        action_results = [r for r in task_results if r.get("task_type") == "action"]

        if diagnosis_results and action_results:
            d_hep = diagnosis_results[0]["final_hep"]
            a_hep = action_results[0]["final_hep"]
            response["joint_hep"] = calculate_joint_hep(d_hep, a_hep)

        # 依赖性修正
        dep_config = data.get("dependency")
        if dep_config:
            dep_level = dep_config.get("level", "zero")
            to_task_idx = dep_config.get("to_task", len(task_results) - 1)

            if 0 <= to_task_idx < len(task_results):
                target_hep = task_results[to_task_idx]["final_hep"]
                dep_result = calculate_dependency(target_hep, dep_level)
                response["dependency_correction"] = dep_result

                final_hep = dep_result["corrected_hep"]
            else:
                final_hep = task_results[-1]["final_hep"]
        elif "joint_hep" in response:
            final_hep = response["joint_hep"]["final_joint_hep"]
        else:
            final_hep = task_results[-1]["final_hep"]

        # 不确定性分析
        response["uncertainty"] = calculate_uncertainty(final_hep)
        response["final_hep"] = round(final_hep, 8)

        return jsonify(response)

    except Exception as e:
        return jsonify({"error": f"计算错误: {str(e)}"}), 500


@spar_h_bp.route("/api/spar-h/hep", methods=["POST"])
def simple_hep():
    """
    简单 HEP 计算接口

    输入 JSON:
    {
        "task_type": "diagnosis" | "action",
        "nominal_hep": 0.01,  // 可选，不提供则按 task_type 取默认值
        "psf_multipliers": [
            {"multiplier": 10, "is_negative": true}
        ]
    }
    """
    try:
        data = request.get_json(force=True)
        if not data:
            return jsonify({"error": "请提供有效的 JSON 请求体"}), 400

        task_type = data.get("task_type", "diagnosis")
        nominal = data.get("nominal_hep", NOMINAL_HEP.get(task_type, 1e-2))
        psf_multipliers = data.get("psf_multipliers", [])

        result = calculate_hep(nominal, psf_multipliers)
        result["task_type"] = task_type
        result["nominal_hep"] = nominal
        return jsonify(result)

    except Exception as e:
        return jsonify({"error": f"HEP 计算错误: {str(e)}"}), 500


@spar_h_bp.route("/api/spar-h/dependency", methods=["POST"])
def dependency_correction():
    """
    依赖性修正接口

    输入 JSON:
    {
        "hep": 0.01,
        "dependency_level": "low" | "moderate" | "high" | "complete" | "zero"
    }
    """
    try:
        data = request.get_json(force=True)
        if not data:
            return jsonify({"error": "请提供有效的 JSON 请求体"}), 400

        hep = data.get("hep")
        level = data.get("dependency_level")

        if hep is None or level is None:
            return jsonify({"error": "需要提供 hep 和 dependency_level"}), 400

        result = calculate_dependency(float(hep), level)
        return jsonify(result)

    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": f"依赖性修正错误: {str(e)}"}), 500


@spar_h_bp.route("/api/spar-h/uncertainty", methods=["POST"])
def uncertainty_analysis():
    """
    不确定性分析接口

    输入 JSON:
    {
        "mean_hep": 0.01
    }
    """
    try:
        data = request.get_json(force=True)
        if not data:
            return jsonify({"error": "请提供有效的 JSON 请求体"}), 400

        mean_hep = data.get("mean_hep")
        if mean_hep is None:
            return jsonify({"error": "需要提供 mean_hep"}), 400

        result = calculate_uncertainty(float(mean_hep))
        return jsonify(result)

    except Exception as e:
        return jsonify({"error": f"不确定性分析错误: {str(e)}"}), 500


@spar_h_bp.route("/api/spar-h/psf-options", methods=["GET"])
def get_psf_options():
    """返回全部 8 项 PSF 的定义及其级别选项"""
    task_type = request.args.get("task_type")

    if task_type and task_type in ("diagnosis", "action"):
        filtered = []
        for psf in PSF_OPTIONS:
            item = {
                "code": psf["code"],
                "name": psf["name"],
                "name_en": psf["name_en"],
                "levels": psf["levels"].get(task_type, []),
            }
            filtered.append(item)
        return jsonify({"task_type": task_type, "psf_options": filtered})

    return jsonify({"psf_options": PSF_OPTIONS})
