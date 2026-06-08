package com.library.libhub.dao;

import com.library.libhub.entity.Users;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.simple.SimpleJdbcInsert;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
public class UserDAO {

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insertUser;

    private static final String TABLE_NAME = "Users";
    private static final String ID_COLUMN = "user_id";

    private static final String SELECT_ALL =
            "SELECT user_id, username, password_hash, full_name, email, phone, address, " +
                    "avatar, status, role_id, created_at, last_login FROM " + TABLE_NAME;

    private static final RowMapper<Users> USER_ROW_MAPPER = (rs, rowNum) -> {
        Users u = new Users();
        u.setUserId(rs.getLong("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setAvatar(rs.getString("avatar"));
        u.setStatus(rs.getString("status"));
        u.setRoleId(rs.getLong("role_id"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setLastLogin(rs.getTimestamp("last_login"));
        return u;
    };

    @Autowired
    public UserDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insertUser = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<Users> findAll() {
        return jdbcTemplate.query(SELECT_ALL, USER_ROW_MAPPER);
    }

    public Optional<Users> findById(long userId) {
        try {
            Users u = jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE user_id = ?",
                    USER_ROW_MAPPER,
                    userId);
            return Optional.ofNullable(u);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public Optional<Users> findByUsername(String username) {
        try {
            Users u = jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE username = ?",
                    USER_ROW_MAPPER,
                    username);
            return Optional.ofNullable(u);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public Optional<Users> findByEmail(String email) {
        try {
            Users u = jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE email = ?",
                    USER_ROW_MAPPER,
                    email);
            return Optional.ofNullable(u);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public long save(Users user) {
        Map<String, Object> params = new HashMap<>();
        params.put("username", user.getUsername());
        params.put("password_hash", user.getPasswordHash());
        params.put("full_name", user.getFullName());
        params.put("email", user.getEmail());
        params.put("phone", user.getPhone());
        params.put("address", user.getAddress());
        params.put("avatar", user.getAvatar());
        params.put("status", user.getStatus());
        params.put("role_id", user.getRoleId());
        params.put("created_at", user.getCreatedAt());
        params.put("last_login", user.getLastLogin());

        Number generatedId = insertUser.executeAndReturnKey(params);
        long newId = generatedId.longValue();
        user.setUserId(newId);
        return newId;
    }

    public int update(Users user) {
        String sql = "UPDATE " + TABLE_NAME + " SET " +
                "username = ?, password_hash = ?, full_name = ?, email = ?, " +
                "phone = ?, address = ?, avatar = ?, status = ?, role_id = ?, last_login = ? " +
                "WHERE user_id = ?";
        return jdbcTemplate.update(sql,
                user.getUsername(),
                user.getPasswordHash(),
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getAddress(),
                user.getAvatar(),
                user.getStatus(),
                user.getRoleId(),
                user.getLastLogin(),
                user.getUserId());
    }

    public int updateLastLogin(long userId, Timestamp lastLogin) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET last_login = ? WHERE user_id = ?",
                lastLogin, userId);
    }

    public int deleteById(long userId) {
        return jdbcTemplate.update(
                "DELETE FROM " + TABLE_NAME + " WHERE user_id = ?",
                userId);
    }

    public boolean existsByUsername(String username) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM " + TABLE_NAME + " WHERE username = ?",
                Integer.class,
                username);
        return count != null && count > 0;
    }
}