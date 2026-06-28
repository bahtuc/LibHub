package com.library.libhub.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.library.libhub.dao.RoleDAO;
import com.library.libhub.entity.Roles;

/**
 * Seed dữ liệu tối thiểu khi khởi động để app dùng được ngay
 * (đăng ký cần sẵn role "Member"). Idempotent — chỉ tạo khi chưa có,
 * nên an toàn cho cả H2 lẫn SQL Server.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    private final RoleDAO roleDAO;

    public DataInitializer(RoleDAO roleDAO) {
        this.roleDAO = roleDAO;
    }

    @Override
    public void run(String... args) {
        ensureRole("Admin", "Quản trị viên");
        ensureRole("Member", "Thành viên");
    }

    private void ensureRole(String name, String description) {
        roleDAO.findByRoleName(name).orElseGet(() -> {
            Roles role = new Roles();
            role.setRoleName(name);
            role.setDescription(description);
            return roleDAO.save(role);
        });
    }
}
