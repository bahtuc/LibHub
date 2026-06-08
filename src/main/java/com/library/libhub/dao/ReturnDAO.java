package com.library.libhub.dao;

import com.library.libhub.entity.Returns;
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
public class ReturnDAO {

    private static final String TABLE_NAME = "Returns";
    private static final String ID_COLUMN = "return_id";

    private static final String SELECT_ALL =
            "SELECT return_id, ticket_id, return_date, received_by, note FROM " + TABLE_NAME;

    private static final RowMapper<Returns> ROW_MAPPER = (rs, rowNum) -> {
        Returns r = new Returns();
        r.setReturnId(rs.getLong("return_id"));
        r.setTicketId(rs.getLong("ticket_id"));
        r.setReturnDate(rs.getDate("return_date"));
        r.setReceivedBy(rs.getLong("received_by"));
        r.setNote(rs.getString("note"));
        return r;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public ReturnDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<Returns> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<Returns> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE return_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<Returns> findByTicketId(long ticketId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE ticket_id = ?", ROW_MAPPER, ticketId);
    }

    public long save(Returns r) {
        Map<String, Object> p = new HashMap<>();
        p.put("ticket_id", r.getTicketId());
        p.put("return_date", r.getReturnDate());
        p.put("received_by", r.getReceivedBy());
        p.put("note", r.getNote());
        long id = insert.executeAndReturnKey(p).longValue();
        r.setReturnId(id);
        return id;
    }

    public int update(Returns r) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME +
                        " SET ticket_id = ?, return_date = ?, received_by = ?, note = ? WHERE return_id = ?",
                r.getTicketId(), r.getReturnDate(), r.getReceivedBy(), r.getNote(), r.getReturnId());
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE return_id = ?", id);
    }
}