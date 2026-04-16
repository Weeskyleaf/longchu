package com.nuclear.hf.controller;

import com.nuclear.hf.dto.ApiResponse;
import com.nuclear.hf.entity.TaskUnit;
import com.nuclear.hf.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @GetMapping
    public ApiResponse<List<TaskUnit>> list(@RequestParam Long event_id) {
        List<TaskUnit> tasks = taskService.findByEventId(event_id);
        return ApiResponse.ok(tasks);
    }

    @PostMapping
    public ApiResponse<TaskUnit> create(@RequestBody TaskUnit task) {
        try {
            TaskUnit created = taskService.create(task);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ApiResponse<TaskUnit> update(@PathVariable Long id, @RequestBody TaskUnit task) {
        try {
            TaskUnit updated = taskService.update(id, task);
            return ApiResponse.ok(updated, "更新成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        try {
            taskService.delete(id);
            return ApiResponse.ok(null, "删除成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(404, e.getMessage());
        }
    }
}
