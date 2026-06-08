package com.library.libhub.dao;

import com.library.libhub.entity.Categories;
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
public class CategoryDAO {

    private static final String TABLE_NAME = "Categories";
    private static final String ID_COLUMN = "category_id";

    private static final String SELECT_ALL =
            "SELECT category_id, category_name, description FROM " + TABLE_NAME;

    private static final RowMapper<Categories> ROW_MAPPER = (rs, rowNum) -> {
        Categories c = new Categories();
        c.setCategoryId(rs.getLong("category_id"));
        c.setCategoryName(rs.getString("category_name"));
        c.setDescription(rs.getString("description"));
        return c;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public CategoryDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<Categories> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<Categories> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE category_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public long save(Categories c) {
        Map<String, Object> p = new HashMap<>();
        p.put("category_name", c.getCategoryName());
        p.put("description", c.getDescription());
        long id = insert.executeAndReturnKey(p).longValue();
        c.setCategoryId(id);
        return id;
    }

    public int update(Categories c) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME +
                        " SET category_name = ?, description = ? WHERE category_id = ?",
                c.getCategoryName(), c.getDescription(), c.getCategoryId());
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE category_id = ?", id);
    }
}