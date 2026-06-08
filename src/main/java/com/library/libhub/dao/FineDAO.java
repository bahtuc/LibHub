package com.library.libhub.dao;

import com.library.libhub.entity.Fines;
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
public class FineDAO {

    private static final String TABLE_NAME = "Fines";
    private static final String ID_COLUMN = "fine_id";

    private static final String SELECT_ALL =
            "SELECT fine_id, return_detail_id, amount, reason, paid_status, created_at FROM " + TABLE_NAME;

    private static final RowMapper<Fines> ROW_MAPPER = (rs, rowNum) -> {
        Fines f = new Fines();
        f.setFineId(rs.getLong("fine_id"));
        f.setReturnDetailId(rs.getLong("return_detail_id"));
        f.setAmount(rs.getDouble("amount"));
        f.setReason(rs.getString("reason"));
        f.setPaidStatus(rs.getString("paid_status"));
        f.setCreatedAt(rs.getTimestamp("created_at"));
        return f;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public FineDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<Fines> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<Fines> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE fine_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<Fines> findByReturnDetailId(long returnDetailId) {
        return jdbcTemplate.query(
                SELECT_ALL + " WHERE return_detail_id = ?", ROW_MAPPER, returnDetailId);
    }

    public List<Fines> findByPaidStatus(String paidStatus) {
        return jdbcTemplate.query(
                SELECT_ALL + " WHERE paid_status = ?", ROW_MAPPER, paidStatus);
    }

    public long save(Fines f) {
        Map<String, Object> p = new HashMap<>();
        p.put("return_detail_id", f.getReturnDetailId());
        p.put("amount", f.getAmount());
        p.put("reason", f.getReason());
        p.put("paid_status", f.getPaidStatus());
        p.put("created_at", f.getCreatedAt());
        long id = insert.executeAndReturnKey(p).longValue();
        f.setFineId(id);
        return id;
    }

    public int update(Fines f) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET return_detail_id = ?, amount = ?, reason = ?, " +
                        "paid_status = ? WHERE fine_id = ?",
                f.getReturnDetailId(), f.getAmount(), f.getReason(),
                f.getPaidStatus(), f.getFineId());
    }

    public int updatePaidStatus(long fineId, String paidStatus) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET paid_status = ? WHERE fine_id = ?",
                paidStatus, fineId);
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE fine_id = ?", id);
    }
}