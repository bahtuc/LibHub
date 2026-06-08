package com.library.libhub.dao;

import com.library.libhub.entity.BorrowDetails;
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
public class BorrowDetailDAO {

    private static final String TABLE_NAME = "BorrowDetails";
    private static final String ID_COLUMN = "detail_id";

    private static final String SELECT_ALL =
            "SELECT detail_id, ticket_id, copy_id, borrow_status FROM " + TABLE_NAME;

    private static final RowMapper<BorrowDetails> ROW_MAPPER = (rs, rowNum) -> {
        BorrowDetails d = new BorrowDetails();
        d.setDetailId(rs.getLong("detail_id"));
        d.setTicketId(rs.getLong("ticket_id"));
        d.setCopyId(rs.getLong("copy_id"));
        d.setBorrowStatus(rs.getString("borrow_status"));
        return d;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public BorrowDetailDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<BorrowDetails> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<BorrowDetails> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE detail_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<BorrowDetails> findByTicketId(long ticketId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE ticket_id = ?", ROW_MAPPER, ticketId);
    }

    public List<BorrowDetails> findByCopyId(long copyId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE copy_id = ?", ROW_MAPPER, copyId);
    }

    public long save(BorrowDetails d) {
        Map<String, Object> p = new HashMap<>();
        p.put("ticket_id", d.getTicketId());
        p.put("copy_id", d.getCopyId());
        p.put("borrow_status", d.getBorrowStatus());
        long id = insert.executeAndReturnKey(p).longValue();
        d.setDetailId(id);
        return id;
    }

    public int update(BorrowDetails d) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME +
                        " SET ticket_id = ?, copy_id = ?, borrow_status = ? WHERE detail_id = ?",
                d.getTicketId(), d.getCopyId(), d.getBorrowStatus(), d.getDetailId());
    }

    public int updateStatus(long detailId, String status) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET borrow_status = ? WHERE detail_id = ?",
                status, detailId);
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE detail_id = ?", id);
    }
}