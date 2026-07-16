package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.RoleDAO;
import com.library.libhub.entity.Roles;
import com.library.libhub.service.IRoleService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class RoleServiceImpl implements IRoleService {

    private final RoleDAO roleDAO;

    public RoleServiceImpl(RoleDAO roleDAO) {
        this.roleDAO = roleDAO;
    }

    @Override
    public Roles createRole(Roles role) {
        validate(role);
        if (roleDAO.findByRoleName(role.getRoleName()).isPresent())
            throw new IllegalArgumentException("Tên vai trò đã tồn tại");
        return roleDAO.save(role);
    }

    @Override
    public Optional<Roles> getRoleById(long roleId) {
        return roleDAO.findById(roleId);
    }

    @Override
    public List<Roles> getAllRoles() {
        return roleDAO.findAll();
    }

    @Override
    public Roles updateRole(long roleId, Roles role) {
        Roles existing = roleDAO.findById(roleId)
                .orElseThrow(() -> new ResourceNotFoundException("Role not found with id: " + roleId));
        if (role.getRoleName() != null) existing.setRoleName(role.getRoleName());
        if (role.getDescription() != null) existing.setDescription(role.getDescription());
        validate(existing);
        roleDAO.findByRoleName(existing.getRoleName())
                .filter(other -> !other.getRoleId().equals(roleId))
                .ifPresent(other -> { throw new IllegalArgumentException("Tên vai trò đã tồn tại"); });
        return roleDAO.save(existing);
    }

    @Override
    public void deleteRole(long roleId) {
        if (roleDAO.existsById(roleId)) {
            roleDAO.deleteById(roleId);
        } else {
            throw new ResourceNotFoundException("Role not found with id: " + roleId);
        }
    }

    @Override
    public Optional<Roles> findByName(String roleName) {
        return roleDAO.findByRoleName(roleName);
    }

    private void validate(Roles role) {
        if (role == null || role.getRoleName() == null || role.getRoleName().isBlank())
            throw new IllegalArgumentException("Tên vai trò không được để trống");
    }
}
