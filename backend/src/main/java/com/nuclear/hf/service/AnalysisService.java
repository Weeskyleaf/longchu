package com.nuclear.hf.service;

import com.nuclear.hf.entity.*;
import com.nuclear.hf.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class AnalysisService {

    private final AnalysisCaseRepository analysisCaseRepository;
    private final CaseTaskRepository caseTaskRepository;
    private final CasePsfValueRepository casePsfValueRepository;
    private final SparhPsfDictRepository sparhPsfDictRepository;
    private final DependencyAssessmentRepository dependencyAssessmentRepository;
    private final UncertaintyResultRepository uncertaintyResultRepository;
    private final EvidenceIndexRepository evidenceIndexRepository;
    private final RestTemplate restTemplate;

    @Value("${spar-h.service.url}")
    private String sparhServiceUrl;

    public List<AnalysisCase> listCases() {
        return analysisCaseRepository.findAll();
    }

    public AnalysisCase getCaseById(Long id) {
        return analysisCaseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("分析案例不存在: " + id));
    }

    public Map<String, Object> getCaseDetail(Long id) {
        AnalysisCase analysisCase = getCaseById(id);
        List<CaseTask> tasks = caseTaskRepository.findByCaseId(id);
        List<DependencyAssessment> dependencies = dependencyAssessmentRepository.findByCaseId(id);
        List<EvidenceIndex> evidences = evidenceIndexRepository.findByCaseId(id);

        Map<Long, List<CasePsfValue>> taskPsfMap = new HashMap<>();
        Map<Long, List<UncertaintyResult>> taskUncertaintyMap = new HashMap<>();
        for (CaseTask task : tasks) {
            taskPsfMap.put(task.getId(), casePsfValueRepository.findByCaseTaskId(task.getId()));
            taskUncertaintyMap.put(task.getId(), uncertaintyResultRepository.findByCaseTaskId(task.getId()));
        }

        Map<String, Object> detail = new HashMap<>();
        detail.put("case", analysisCase);
        detail.put("tasks", tasks);
        detail.put("taskPsfValues", taskPsfMap);
        detail.put("taskUncertainties", taskUncertaintyMap);
        detail.put("dependencies", dependencies);
        detail.put("evidences", evidences);
        return detail;
    }

    @Transactional
    public AnalysisCase createCase(AnalysisCase analysisCase) {
        return analysisCaseRepository.save(analysisCase);
    }

    @Transactional
    public AnalysisCase updateCase(Long id, AnalysisCase updated) {
        AnalysisCase existing = getCaseById(id);
        updated.setId(existing.getId());
        updated.setCreatedAt(existing.getCreatedAt());
        return analysisCaseRepository.save(updated);
    }

    @Transactional
    public void deleteCase(Long id) {
        if (!analysisCaseRepository.existsById(id)) {
            throw new RuntimeException("分析案例不存在: " + id);
        }
        analysisCaseRepository.deleteById(id);
    }

    @Transactional
    public CaseTask addCaseTask(Long caseId, CaseTask caseTask, List<CasePsfValue> psfValues) {
        getCaseById(caseId);
        caseTask.setCaseId(caseId);
        CaseTask saved = caseTaskRepository.save(caseTask);

        if (psfValues != null) {
            for (CasePsfValue psf : psfValues) {
                psf.setCaseTaskId(saved.getId());
                casePsfValueRepository.save(psf);
            }
        }
        return saved;
    }

    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> triggerCalculation(Long caseId) {
        AnalysisCase analysisCase = getCaseById(caseId);
        List<CaseTask> tasks = caseTaskRepository.findByCaseId(caseId);

        if (tasks.isEmpty()) {
            throw new RuntimeException("案例无任务，无法计算");
        }

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("case_id", caseId);
        requestBody.put("case_code", analysisCase.getCaseCode());

        List<Map<String, Object>> taskList = tasks.stream().map(task -> {
            Map<String, Object> taskMap = new HashMap<>();
            taskMap.put("task_id", task.getId());
            taskMap.put("task_type", task.getTaskType());
            taskMap.put("nominal_hep", task.getNominalHep());

            List<CasePsfValue> psfValues = casePsfValueRepository.findByCaseTaskId(task.getId());
            List<Map<String, Object>> psfList = psfValues.stream().map(psf -> {
                Map<String, Object> psfMap = new HashMap<>();
                psfMap.put("psf_code", psf.getPsfCode());
                psfMap.put("level_code", psf.getLevelCode());
                psfMap.put("multiplier", psf.getMultiplier());
                psfMap.put("is_negative", psf.getIsNegative());
                return psfMap;
            }).toList();
            taskMap.put("psf_values", psfList);
            return taskMap;
        }).toList();
        requestBody.put("tasks", taskList);

        Map<String, Object> calcResult;
        try {
            String url = sparhServiceUrl + "/calculate";
            calcResult = restTemplate.postForObject(url, requestBody, Map.class);
        } catch (Exception e) {
            log.warn("Flask SPAR-H服务调用失败，使用本地计算: {}", e.getMessage());
            calcResult = localCalculation(tasks);
        }

        if (calcResult != null) {
            saveCalculationResults(tasks, calcResult);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("caseId", caseId);
        result.put("calcResult", calcResult);
        result.put("tasks", caseTaskRepository.findByCaseId(caseId));
        return result;
    }

    @SuppressWarnings("unchecked")
    private void saveCalculationResults(List<CaseTask> tasks, Map<String, Object> calcResult) {
        List<Map<String, Object>> taskResults = (List<Map<String, Object>>) calcResult.get("tasks");
        if (taskResults == null) return;

        for (Map<String, Object> taskResult : taskResults) {
            Number taskIdNum = (Number) taskResult.get("task_id");
            if (taskIdNum == null) continue;
            Long taskId = taskIdNum.longValue();

            caseTaskRepository.findById(taskId).ifPresent(task -> {
                if (taskResult.get("composite_psf") != null) {
                    task.setCompositePsf(new BigDecimal(taskResult.get("composite_psf").toString()));
                }
                if (taskResult.get("raw_hep") != null) {
                    task.setRawHep(new BigDecimal(taskResult.get("raw_hep").toString()));
                }
                if (taskResult.get("adjusted_hep") != null) {
                    task.setAdjustedHep(new BigDecimal(taskResult.get("adjusted_hep").toString()));
                }
                if (taskResult.get("negative_count") != null) {
                    task.setNegativeCount(((Number) taskResult.get("negative_count")).intValue());
                }
                if (taskResult.get("final_hep") != null) {
                    task.setFinalHep(new BigDecimal(taskResult.get("final_hep").toString()));
                }
                task.setCalcNote("SPAR-H计算完成");
                caseTaskRepository.save(task);
            });

            Map<String, Object> uncertainty = (Map<String, Object>) taskResult.get("uncertainty");
            if (uncertainty != null) {
                UncertaintyResult ur = new UncertaintyResult();
                ur.setCaseTaskId(taskId);
                ur.setDistType(uncertainty.getOrDefault("dist_type", "Beta").toString());
                if (uncertainty.get("alpha") != null) ur.setAlphaParam(new BigDecimal(uncertainty.get("alpha").toString()));
                if (uncertainty.get("beta") != null) ur.setBetaParam(new BigDecimal(uncertainty.get("beta").toString()));
                if (uncertainty.get("error_factor") != null) ur.setErrorFactor(new BigDecimal(uncertainty.get("error_factor").toString()));
                if (uncertainty.get("mean_hep") != null) ur.setMeanHep(new BigDecimal(uncertainty.get("mean_hep").toString()));
                if (uncertainty.get("median_hep") != null) ur.setMedianHep(new BigDecimal(uncertainty.get("median_hep").toString()));
                if (uncertainty.get("p05") != null) ur.setP05(new BigDecimal(uncertainty.get("p05").toString()));
                if (uncertainty.get("p50") != null) ur.setP50(new BigDecimal(uncertainty.get("p50").toString()));
                if (uncertainty.get("p95") != null) ur.setP95(new BigDecimal(uncertainty.get("p95").toString()));
                uncertaintyResultRepository.save(ur);
            }
        }
    }

    private Map<String, Object> localCalculation(List<CaseTask> tasks) {
        List<Map<String, Object>> taskResults = tasks.stream().map(task -> {
            List<CasePsfValue> psfValues = casePsfValueRepository.findByCaseTaskId(task.getId());

            BigDecimal compositePsf = BigDecimal.ONE;
            int negativeCount = 0;
            for (CasePsfValue psf : psfValues) {
                compositePsf = compositePsf.multiply(psf.getMultiplier());
                if (psf.getIsNegative() != null && psf.getIsNegative() == 1) {
                    negativeCount++;
                }
            }

            BigDecimal nominalHep = task.getNominalHep();
            BigDecimal rawHep = nominalHep.multiply(compositePsf);

            BigDecimal adjustedHep;
            if (negativeCount >= 3) {
                adjustedHep = rawHep.divide(rawHep.add(BigDecimal.ONE), 10, java.math.RoundingMode.HALF_UP);
            } else {
                adjustedHep = rawHep;
            }
            BigDecimal finalHep = adjustedHep.min(BigDecimal.ONE);

            Map<String, Object> result = new HashMap<>();
            result.put("task_id", task.getId());
            result.put("composite_psf", compositePsf);
            result.put("raw_hep", rawHep);
            result.put("adjusted_hep", adjustedHep);
            result.put("negative_count", negativeCount);
            result.put("final_hep", finalHep);
            return result;
        }).toList();

        Map<String, Object> calcResult = new HashMap<>();
        calcResult.put("tasks", taskResults);
        calcResult.put("method", "local");
        return calcResult;
    }

    public List<SparhPsfDict> getPsfDict(String plantMode, String taskType) {
        if (plantMode != null && taskType != null) {
            return sparhPsfDictRepository.findByPlantModeAndTaskType(plantMode, taskType);
        }
        return sparhPsfDictRepository.findAll();
    }

    @Transactional
    public DependencyAssessment addDependency(Long caseId, DependencyAssessment dependency) {
        getCaseById(caseId);
        dependency.setCaseId(caseId);
        return dependencyAssessmentRepository.save(dependency);
    }
}
