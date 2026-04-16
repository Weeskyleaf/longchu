package com.nuclear.hf.controller;

import com.nuclear.hf.dto.ApiResponse;
import com.nuclear.hf.entity.EvidenceChain;
import com.nuclear.hf.service.EvidenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/evidence")
@RequiredArgsConstructor
public class EvidenceController {

    private final EvidenceService evidenceService;

    @GetMapping
    public ApiResponse<List<EvidenceChain>> list(@RequestParam Long event_id) {
        List<EvidenceChain> evidences = evidenceService.findByEventId(event_id);
        return ApiResponse.ok(evidences);
    }

    @PostMapping
    public ApiResponse<EvidenceChain> create(@RequestBody EvidenceChain evidence) {
        try {
            EvidenceChain created = evidenceService.create(evidence);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ApiResponse<EvidenceChain> update(@PathVariable Long id, @RequestBody EvidenceChain evidence) {
        try {
            EvidenceChain updated = evidenceService.update(id, evidence);
            return ApiResponse.ok(updated, "更新成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }
}
