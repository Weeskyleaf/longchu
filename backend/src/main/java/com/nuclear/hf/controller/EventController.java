package com.nuclear.hf.controller;

import com.nuclear.hf.dto.ApiResponse;
import com.nuclear.hf.entity.EventMain;
import com.nuclear.hf.service.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @GetMapping
    public ApiResponse<Map<String, Object>> list(
            @RequestParam(required = false) String event_type,
            @RequestParam(required = false) String unit_no,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<EventMain> result = eventService.listEvents(event_type, unit_no, keyword, pageable);
        return ApiResponse.ok(Map.of("list", result.getContent(), "total", result.getTotalElements()));
    }

    @GetMapping("/{id}")
    public ApiResponse<Map<String, Object>> detail(@PathVariable Long id) {
        try {
            Map<String, Object> detail = eventService.getEventDetail(id);
            return ApiResponse.ok(detail);
        } catch (RuntimeException e) {
            return ApiResponse.error(404, e.getMessage());
        }
    }

    @PostMapping
    public ApiResponse<EventMain> create(@RequestBody EventMain event) {
        try {
            EventMain created = eventService.createEvent(event);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ApiResponse<EventMain> update(@PathVariable Long id, @RequestBody EventMain event) {
        try {
            EventMain updated = eventService.updateEvent(id, event);
            return ApiResponse.ok(updated, "更新成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        try {
            eventService.deleteEvent(id);
            return ApiResponse.ok(null, "删除成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(404, e.getMessage());
        }
    }

    @GetMapping("/stats/overview")
    public ApiResponse<Map<String, Object>> statistics() {
        Map<String, Object> stats = eventService.getStatistics();
        return ApiResponse.ok(stats);
    }
}
