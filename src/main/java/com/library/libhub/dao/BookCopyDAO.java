package com.library.libhub.dao;

import com.library.libhub.entity.BookCopies;
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
public class BookCopyDAO {

    private static final String TABLE_NAME = "BookCopies";
    private static final String ID_COLUMN = "copy_id";

    private static final String SELECT_ALL =
            "SELECT copy_id, book_id, barcode, shelf_location, status, acquired_date FROM " + TABLE_NAME;

    private static final RowMapper<BookCopies> ROW_MAPPER = (rs, rowNum) -> {
        BookCopies c = new BookCopies();
        c.setCopyId(rs.getLong("copy_id"));
        c.setBookId(rs.getLong("book_id"));
        c.setBarcode(rs.getString("barcode"));
        c.setShelfLocation(rs.getString("shelf_location"));
        c.setStatus(rs.getString("status"));
        c.setAcquiredDate(rs.getDate("acquired_date"));
        return c;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public BookCopyDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<BookCopies> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<BookCopies> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE copy_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public Optional<BookCopies> findByBarcode(String barcode) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE barcode = ?", ROW_MAPPER, barcode));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<BookCopies> findByBookId(long bookId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE book_id = ?", ROW_MAPPER, bookId);
    }

    public List<BookCopies> findAvailableByBookId(long bookId) {
        return jdbcTemplate.query(
                SELECT_ALL + " WHERE book_id = ? AND status = 'AVAILABLE'",
                ROW_MAPPER, bookId);
    }

    public long save(BookCopies c) {
        Map<String, Object> p = new HashMap<>();
        p.put("book_id", c.getBookId());
        p.put("barcode", c.getBarcode());
        p.put("shelf_location", c.getShelfLocation());
        p.put("status", c.getStatus());
        p.put("acquired_date", c.getAcquiredDate());
        long id = insert.executeAndReturnKey(p).longValue();
        c.setCopyId(id);
        return id;
    }

    public int update(BookCopies c) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET book_id = ?, barcode = ?, shelf_location = ?, " +
                        "status = ?, acquired_date = ? WHERE copy_id = ?",
                c.getBookId(), c.getBarcode(), c.getShelfLocation(),
                c.getStatus(), c.getAcquiredDate(), c.getCopyId());
    }

    public int updateStatus(long copyId, String status) {
        return jdbcTemplate.update(
                "UPDATE " + TABLE_NAME + " SET status = ? WHERE copy_id = ?", status, copyId);
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE copy_id = ?", id);
    }
}