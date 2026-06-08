package com.library.libhub.dao;

import com.library.libhub.entity.Publishers;
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
public class PublisherDAO {

    private static final String TABLE_NAME = "Publishers";
    private static final String ID_COLUMN = "publisher_id";

    private static final String SELECT_ALL =
            "SELECT publisher_id, publisher_name, address, phone FROM " + TABLE_NAME;

    private static final RowMapper<Publishers> ROW_MAPPER = (rs, rowNum) -> {
        Publishers p = new Publishers();
        p.setPublisherId(rs.getLong("publisher_id"));
        p.setPublisherName(rs.getString("publisher_name"));
        p.setAddress(rs.getString("address"));
        p.setPhone(rs.getString("phone"));
        return p;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public PublisherDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<Publishers> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<Publishers> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE publisher_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public long save(Publishers p) {
        Map<String, Object> params = new HashMap<>();
        params.put("publisher_name", p.getPublisherName());
        params.put("address", p.getAddress());
        params.put("phone", p.getPhone());
        long id = insert.executeAndReturnKey(params).longValue();
        p.setPublisherId(id);
        return id;
    }

    public int update(Publishers p) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME +
                        " SET publisher_name = ?, address = ?, phone = ? WHERE publisher_id = ?",
                p.getPublisherName(), p.getAddress(), p.getPhone(), p.getPublisherId());
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE publisher_id = ?", id);
    }
}