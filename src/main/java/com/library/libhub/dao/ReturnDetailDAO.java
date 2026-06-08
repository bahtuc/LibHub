
package com.library.libhub.dao;

import com.library.libhub.entity.ReturnDetails;
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
public class ReturnDetailDAO {

    private static final String TABLE_NAME = "ReturnDetails";
    private static final String ID_COLUMN = "return_detail_id";

    private static final String SELECT_ALL =
            "SELECT return_detail_id, return_id, copy_id, condition_book FROM " + TABLE_NAME;

    private static final RowMapper<ReturnDetails> ROW_MAPPER = (rs, rowNum) -> {
        ReturnDetails d = new ReturnDetails();
        d.setReturnDetailId(rs.getLong("return_detail_id"));
        d.setReturnId(rs.getLong("return_id"));
        d.setCopyId(rs.getLong("copy_id"));
        d.setConditionBook(rs.getString("condition_book"));
        return d;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public ReturnDetailDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<ReturnDetails> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<ReturnDetails> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE return_detail_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<ReturnDetails> findByReturnId(long returnId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE return_id = ?", ROW_MAPPER, returnId);
    }

    public List<ReturnDetails> findByCopyId(long copyId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE copy_id = ?", ROW_MAPPER, copyId);
    }

    public long save(ReturnDetails d) {
        Map<String, Object> p = new HashMap<>();
        p.put("return_id", d.getReturnId());
        p.put("copy_id", d.getCopyId());
        p.put("condition_book", d.getConditionBook());
        long id = insert.executeAndReturnKey(p).longValue();
        d.setReturnDetailId(id);
        return id;
    }

    public int update(ReturnDetails d) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME +
                        " SET return_id = ?, copy_id = ?, condition_book = ? WHERE return_detail_id = ?",
                d.getReturnId(), d.getCopyId(), d.getConditionBook(), d.getReturnDetailId());
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE return_detail_id = ?", id);
    }
}