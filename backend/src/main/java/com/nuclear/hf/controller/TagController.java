package com.nuclear.hf.controller;

import com.nuclear.hf.dto.ApiResponse;
import com.nuclear.hf.entity.EventTag;
import com.nuclear.hf.entity.TagDict;
import com.nuclear.hf.service.TagService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tags")
@RequiredArgsConstructor
public class TagController {

    private final TagService tagService;

    @GetMapping("/dict")
    public ApiResponse<List<TagDict>> listDict(@RequestParam(required = false) String tagType) {
        List<TagDict> list = tagType != null ? tagService.listByType(tagType) : tagService.listDict();
        return ApiResponse.ok(list);
    }

    @PostMapping("/dict")
    public ApiResponse<TagDict> createDict(@RequestBody TagDict tagDict) {
        try {
            TagDict created = tagService.createDict(tagDict);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PostMapping("/bindEvent")
    public ApiResponse<EventTag> bindEvent(@RequestBody EventTag eventTag) {
        try {
            EventTag created = tagService.bindTag(eventTag);
            return ApiResponse.ok(created, "绑定成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @DeleteMapping("/bindEvent/{id}")
    public ApiResponse<Void> unbindEvent(@PathVariable Long id) {
        try {
            tagService.unbindTag(id);
            return ApiResponse.ok(null, "解绑成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(404, e.getMessage());
        }
    }
}
