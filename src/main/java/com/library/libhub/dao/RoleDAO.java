package com.library.libhub.dao;

import com.library.libhub.entity.Roles;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.simple.SimpleJdbcInsert;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
public class RoleDAO {

    private static final String TABLE_NAME = "Roles";
    private static final String ID_COLUMN = "role_id";

    private static final String SELECT_ALL =
            "SELECT role_id, role_name, description FROM " + TABLE_NAME;

    private static final RowMapper<Roles> ROW_MAPPER = (rs, rowNum) -> {
        Roles r = new Roles();
        r.setRoleId(rs.getLong("role_id"));
        r.setRoleName(rs.getString("role_name"));
        r.setDescription(rs.getString("description"));
        return r;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public RoleDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<Roles> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<Roles> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE role_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public Optional<Roles> findByName(String name) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE role_name = ?", ROW_MAPPER, name));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public long save(Roles r) {
        Map<String, Object> p = new HashMap<>();
        p.put("role_name", r.getRoleName());
        p.put("description", r.getDescription());
        long id = insert.executeAndReturnKey(p).longValue();
        r.setRoleId(id);
        return id;
    }

    public int update(Roles r) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME +
                        " SET role_name = ?, description = ? WHERE role_id = ?",
                r.getRoleName(), r.getDescription(), r.getRoleId());
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE role_id = ?", id);
    }
}