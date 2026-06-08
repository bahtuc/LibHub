package com.library.libhub.dao;

import com.library.libhub.entity.Authors;
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
public class AuthorDAO {

    private static final String TABLE_NAME = "Authors";
    private static final String ID_COLUMN = "author_id";

    private static final String SELECT_ALL =
            "SELECT author_id, author_name, biography FROM " + TABLE_NAME;

    private static final RowMapper<Authors> ROW_MAPPER = (rs, rowNum) -> {
        Authors a = new Authors();
        a.setAuthorId(rs.getLong("author_id"));
        a.setAuthorName(rs.getString("author_name"));
        a.setBiography(rs.getString("biography"));
        return a;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public AuthorDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<Authors> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<Authors> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE author_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public long save(Authors a) {
        Map<String, Object> p = new HashMap<>();
        p.put("author_name", a.getAuthorName());
        p.put("biography", a.getBiography());
        long id = insert.executeAndReturnKey(p).longValue();
        a.setAuthorId(id);
        return id;
    }

    public int update(Authors a) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET author_name = ?, biography = ? WHERE author_id = ?",
                a.getAuthorName(), a.getBiography(), a.getAuthorId());
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE author_id = ?", id);
    }
}