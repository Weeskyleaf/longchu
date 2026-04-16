package com.nuclear.hf.controller;

import com.nuclear.hf.dto.ApiResponse;
import com.nuclear.hf.entity.SysUser;
import com.nuclear.hf.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/login")
    public ApiResponse<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        try {
            String username = body.get("username");
            String password = body.get("password");
            if (username == null || password == null) {
                return ApiResponse.error(400, "用户名和密码不能为空");
            }
            Map<String, Object> result = userService.login(username, password);
            return ApiResponse.ok(result, "登录成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(401, e.getMessage());
        }
    }

    @PostMapping("/register")
    public ApiResponse<SysUser> register(@RequestBody SysUser user) {
        try {
            SysUser created = userService.register(user);
            created.setPasswordHash(null);
            return ApiResponse.ok(created, "注册成功");
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }
}
