package com.nuclear.hf.controller;

import com.nuclear.hf.dto.ApiResponse;
import com.nuclear.hf.entity.ImpactFactor;
import com.nuclear.hf.service.FactorService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/factors")
@RequiredArgsConstructor
public class FactorController {

    private final FactorService factorService;

    @GetMapping
    public ApiResponse<List<ImpactFactor>> list(@RequestParam Long event_id) {
        List<ImpactFactor> factors = factorService.findByEventId(event_id);
        return ApiResponse.ok(factors);
    }

    @PostMapping
    public ApiResponse<ImpactFactor> create(@RequestBody ImpactFactor factor) {
        try {
            ImpactFactor created = factorService.create(factor);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ApiResponse<ImpactFactor> update(@PathVariable Long id, @RequestBody ImpactFactor factor) {
        try {
            ImpactFactor updated = factorService.update(id, factor);
            return ApiResponse.ok(updated, "更新成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        try {
            factorService.delete(id);
            return ApiResponse.ok(null, "删除成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(404, e.getMessage());
        }
    }
}
