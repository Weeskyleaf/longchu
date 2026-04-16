package com.nuclear.hf.controller;

import com.nuclear.hf.dto.ApiResponse;
import com.nuclear.hf.entity.*;
import com.nuclear.hf.service.AnalysisService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/analysis")
@RequiredArgsConstructor
public class AnalysisController {

    private final AnalysisService analysisService;

    @GetMapping("/cases")
    public ApiResponse<List<AnalysisCase>> listCases() {
        List<AnalysisCase> cases = analysisService.listCases();
        return ApiResponse.ok(cases);
    }

    @GetMapping("/cases/{id}")
    public ApiResponse<Map<String, Object>> caseDetail(@PathVariable Long id) {
        try {
            Map<String, Object> detail = analysisService.getCaseDetail(id);
            return ApiResponse.ok(detail);
        } catch (RuntimeException e) {
            return ApiResponse.error(404, e.getMessage());
        }
    }

    @PostMapping("/cases")
    public ApiResponse<AnalysisCase> createCase(@RequestBody AnalysisCase analysisCase) {
        try {
            AnalysisCase created = analysisService.createCase(analysisCase);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PutMapping("/cases/{id}")
    public ApiResponse<AnalysisCase> updateCase(@PathVariable Long id, @RequestBody AnalysisCase analysisCase) {
        try {
            AnalysisCase updated = analysisService.updateCase(id, analysisCase);
            return ApiResponse.ok(updated, "更新成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @DeleteMapping("/cases/{id}")
    public ApiResponse<Void> deleteCase(@PathVariable Long id) {
        try {
            analysisService.deleteCase(id);
            return ApiResponse.ok(null, "删除成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(404, e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    @PostMapping("/cases/{id}/tasks")
    public ApiResponse<CaseTask> addCaseTask(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        try {
            CaseTask caseTask = new CaseTask();
            caseTask.setTaskType((String) body.get("taskType"));
            if (body.get("nominalHep") != null) {
                caseTask.setNominalHep(new java.math.BigDecimal(body.get("nominalHep").toString()));
            }

            List<CasePsfValue> psfValues = null;
            List<Map<String, Object>> psfList = (List<Map<String, Object>>) body.get("psfValues");
            if (psfList != null) {
                psfValues = psfList.stream().map(m -> {
                    CasePsfValue psf = new CasePsfValue();
                    psf.setPsfCode((String) m.get("psfCode"));
                    psf.setPsfName((String) m.get("psfName"));
                    psf.setLevelCode((String) m.get("levelCode"));
                    psf.setLevelName((String) m.get("levelName"));
                    if (m.get("multiplier") != null) {
                        psf.setMultiplier(new java.math.BigDecimal(m.get("multiplier").toString()));
                    }
                    if (m.get("isNegative") != null) {
                        psf.setIsNegative(((Number) m.get("isNegative")).intValue());
                    }
                    psf.setBasisText((String) m.get("basisText"));
                    return psf;
                }).toList();
            }

            CaseTask created = analysisService.addCaseTask(id, caseTask, psfValues);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PostMapping("/cases/{id}/calculate")
    public ApiResponse<Map<String, Object>> calculate(@PathVariable Long id) {
        try {
            Map<String, Object> result = analysisService.triggerCalculation(id);
            return ApiResponse.ok(result, "计算完成");
        } catch (RuntimeException e) {
            return ApiResponse.error(500, e.getMessage());
        }
    }

    @GetMapping("/psf-dict")
    public ApiResponse<List<SparhPsfDict>> getPsfDict(
            @RequestParam(required = false) String plantMode,
            @RequestParam(required = false) String taskType) {
        List<SparhPsfDict> dict = analysisService.getPsfDict(plantMode, taskType);
        return ApiResponse.ok(dict);
    }

    @PostMapping("/cases/{id}/dependency")
    public ApiResponse<DependencyAssessment> addDependency(
            @PathVariable Long id,
            @RequestBody DependencyAssessment dependency) {
        try {
            DependencyAssessment created = analysisService.addDependency(id, dependency);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }
}
