package com.library.libhub.service;

import com.library.libhub.entity.Roles;
import java.util.List;
import java.util.Optional;

public interface IRoleService {
    Roles createRole(Roles role);
    Optional<Roles> getRoleById(Long roleId);
    List<Roles> getAllRoles();
    Roles updateRole(Long roleId, Roles role);
    void deleteRole(Long roleId);
    Optional<Roles> findByName(String roleName);
}
