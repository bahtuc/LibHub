package com.library.libhub.service.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.entity.Roles;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.RoleRepository;
import com.library.libhub.service.IRoleService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class RoleServiceImpl implements IRoleService {

    private final RoleRepository roleRepo;

    public RoleServiceImpl(RoleRepository roleRepo) {
        this.roleRepo = roleRepo;
    }

    @Override
    public Roles createRole(Roles role) {
        validate(role);
        if (roleRepo.findByRoleName(role.getRoleName()).isPresent())
            throw new IllegalArgumentException("Tên vai trò đã tồn tại");
        return roleRepo.save(role);
    }

    @Override
    public Optional<Roles> getRoleById(long roleId) {
        return roleRepo.findById(roleId);
    }

    @Override
    public List<Roles> getAllRoles() {
        return roleRepo.findAll();
    }

    @Override
    public Roles updateRole(long roleId, Roles role) {
        Roles existing = roleRepo.findById(roleId)
                .orElseThrow(() -> new ResourceNotFoundException("Role not found with id: " + roleId));
        if (role.getRoleName() != null) existing.setRoleName(role.getRoleName());
        if (role.getDescription() != null) existing.setDescription(role.getDescription());
        validate(existing);
        roleRepo.findByRoleName(existing.getRoleName())
                .filter(other -> !other.getRoleId().equals(roleId))
                .ifPresent(other -> { throw new IllegalArgumentException("Tên vai trò đã tồn tại"); });
        return roleRepo.save(existing);
    }

    @Override
    public void deleteRole(long roleId) {
        if (roleRepo.existsById(roleId)) {
            roleRepo.deleteById(roleId);
        } else {
            throw new ResourceNotFoundException("Role not found with id: " + roleId);
        }
    }

    @Override
    public Optional<Roles> findByName(String roleName) {
        return roleRepo.findByRoleName(roleName);
    }

    private void validate(Roles role) {
        if (role == null || role.getRoleName() == null || role.getRoleName().isBlank())
            throw new IllegalArgumentException("Tên vai trò không được để trống");
    }
}
