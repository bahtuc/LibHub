package com.library.libhub.service;

import com.library.libhub.entity.Roles;
import java.util.List;
import java.util.Optional;

public interface IRoleService {
    Roles createRole(Roles role);
    Optional<Roles> getRoleById(long roleId);
    List<Roles> getAllRoles();
    Roles updateRole(long roleId, Roles role);
    void deleteRole(long roleId);
    Optional<Roles> findByName(String roleName);
}
