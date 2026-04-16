package com.nuclear.hf.controller;

import com.nuclear.hf.dto.ApiResponse;
import com.nuclear.hf.entity.EventPerson;
import com.nuclear.hf.entity.PersonInfo;
import com.nuclear.hf.service.PersonService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/persons")
@RequiredArgsConstructor
public class PersonController {

    private final PersonService personService;

    @GetMapping
    public ApiResponse<List<PersonInfo>> list() {
        List<PersonInfo> persons = personService.listAll();
        return ApiResponse.ok(persons);
    }

    @PostMapping
    public ApiResponse<PersonInfo> create(@RequestBody PersonInfo person) {
        try {
            PersonInfo created = personService.create(person);
            return ApiResponse.ok(created, "创建成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ApiResponse<PersonInfo> update(@PathVariable Long id, @RequestBody PersonInfo person) {
        try {
            PersonInfo updated = personService.update(id, person);
            return ApiResponse.ok(updated, "更新成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PostMapping("/bindEvent")
    public ApiResponse<EventPerson> bindEvent(@RequestBody EventPerson eventPerson) {
        try {
            EventPerson created = personService.linkEvent(eventPerson);
            return ApiResponse.ok(created, "绑定成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @DeleteMapping("/bindEvent/{id}")
    public ApiResponse<Void> unbindEvent(@PathVariable Long id) {
        try {
            personService.unlinkEvent(id);
            return ApiResponse.ok(null, "解绑成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(404, e.getMessage());
        }
    }
}
