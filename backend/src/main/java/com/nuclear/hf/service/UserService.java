package com.nuclear.hf.service;

import com.nuclear.hf.entity.SysUser;
import com.nuclear.hf.repository.SysUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class UserService {

    private final SysUserRepository sysUserRepository;

    public Map<String, Object> login(String username, String password) {
        SysUser user = sysUserRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        if (!user.getPasswordHash().equals(password)) {
            throw new RuntimeException("密码错误");
        }

        if (user.getIsActive() != 1) {
            throw new RuntimeException("账号已停用");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", user.getId());
        result.put("username", user.getUsername());
        result.put("realName", user.getRealName());
        result.put("role", user.getRole());
        return result;
    }

    @Transactional
    public SysUser register(SysUser user) {
        if (sysUserRepository.findByUsername(user.getUsername()).isPresent()) {
            throw new RuntimeException("用户名已存在");
        }
        return sysUserRepository.save(user);
    }
}
