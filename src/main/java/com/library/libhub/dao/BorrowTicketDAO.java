package com.library.libhub.dao;

import com.library.libhub.entity.BorrowTickets;
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
public class BorrowTicketDAO {

    private static final String TABLE_NAME = "BorrowTickets";
    private static final String ID_COLUMN = "ticket_id";

    private static final String SELECT_ALL =
            "SELECT ticket_id, user_id, borrow_date, due_date, status, note, created_at FROM " + TABLE_NAME;

    private static final RowMapper<BorrowTickets> ROW_MAPPER = (rs, rowNum) -> {
        BorrowTickets t = new BorrowTickets();
        t.setTicketId(rs.getLong("ticket_id"));
        t.setUserId(rs.getLong("user_id"));
        t.setBorrowDate(rs.getDate("borrow_date"));
        t.setDueDate(rs.getDate("due_date"));
        t.setStatus(rs.getString("status"));
        t.setNote(rs.getString("note"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        return t;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public BorrowTicketDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<BorrowTickets> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<BorrowTickets> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE ticket_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<BorrowTickets> findByUserId(long userId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE user_id = ?", ROW_MAPPER, userId);
    }

    public List<BorrowTickets> findByStatus(String status) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE status = ?", ROW_MAPPER, status);
    }

    public long save(BorrowTickets t) {
        Map<String, Object> p = new HashMap<>();
        p.put("user_id", t.getUserId());
        p.put("borrow_date", t.getBorrowDate());
        p.put("due_date", t.getDueDate());
        p.put("status", t.getStatus());
        p.put("note", t.getNote());
        p.put("created_at", t.getCreatedAt());
        long id = insert.executeAndReturnKey(p).longValue();
        t.setTicketId(id);
        return id;
    }

    public int update(BorrowTickets t) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET user_id = ?, borrow_date = ?, due_date = ?, " +
                        "status = ?, note = ? WHERE ticket_id = ?",
                t.getUserId(), t.getBorrowDate(), t.getDueDate(),
                t.getStatus(), t.getNote(), t.getTicketId());
    }

    public int updateStatus(long ticketId, String status) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET status = ? WHERE ticket_id = ?", status, ticketId);
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE ticket_id = ?", id);
    }
}