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
        if (roleDAO.existsById(roleId)) {
            role.setRoleId(roleId);
            return roleDAO.save(role);
        }
        throw new ResourceNotFoundException("Role not found with id: " + roleId);
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
}
