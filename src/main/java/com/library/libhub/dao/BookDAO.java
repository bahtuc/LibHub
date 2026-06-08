package com.library.libhub.dao;

import com.library.libhub.entity.Books;
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
public class BookDAO {

    private static final String TABLE_NAME = "Books";
    private static final String ID_COLUMN = "book_id";

    private static final String SELECT_ALL =
            "SELECT book_id, title, isbn, publish_year, description, cover_image, language, " +
                    "pages, category_id, author_id, publisher_id, created_at FROM " + TABLE_NAME;

    private static final RowMapper<Books> ROW_MAPPER = (rs, rowNum) -> {
        Books b = new Books();
        b.setBookId(rs.getLong("book_id"));
        b.setTitle(rs.getString("title"));
        b.setIsbn(rs.getString("isbn"));
        b.setPublishYear(rs.getLong("publish_year"));
        b.setDescription(rs.getString("description"));
        b.setCoverImage(rs.getString("cover_image"));
        b.setLanguage(rs.getString("language"));
        b.setPages(rs.getLong("pages"));
        b.setCategoryId(rs.getLong("category_id"));
        b.setAuthorId(rs.getLong("author_id"));
        b.setPublisherId(rs.getLong("publisher_id"));
        b.setCreatedAt(rs.getTimestamp("created_at"));
        return b;
    };

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert insert;

    public BookDAO(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.insert = new SimpleJdbcInsert(dataSource)
                .withTableName(TABLE_NAME)
                .usingGeneratedKeyColumns(ID_COLUMN);
    }

    public List<Books> findAll() {
        return jdbcTemplate.query(SELECT_ALL, ROW_MAPPER);
    }

    public Optional<Books> findById(long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE book_id = ?", ROW_MAPPER, id));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public Optional<Books> findByIsbn(String isbn) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    SELECT_ALL + " WHERE isbn = ?", ROW_MAPPER, isbn));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<Books> findByCategoryId(long categoryId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE category_id = ?", ROW_MAPPER, categoryId);
    }

    public List<Books> findByAuthorId(long authorId) {
        return jdbcTemplate.query(SELECT_ALL + " WHERE author_id = ?", ROW_MAPPER, authorId);
    }

    public List<Books> searchByTitle(String keyword) {
        return jdbcTemplate.query(
                SELECT_ALL + " WHERE title LIKE ?", ROW_MAPPER, "%" + keyword + "%");
    }

    public long save(Books b) {
        Map<String, Object> p = new HashMap<>();
        p.put("title", b.getTitle());
        p.put("isbn", b.getIsbn());
        p.put("publish_year", b.getPublishYear());
        p.put("description", b.getDescription());
        p.put("cover_image", b.getCoverImage());
        p.put("language", b.getLanguage());
        p.put("pages", b.getPages());
        p.put("category_id", b.getCategoryId());
        p.put("author_id", b.getAuthorId());
        p.put("publisher_id", b.getPublisherId());
        p.put("created_at", b.getCreatedAt());
        long id = insert.executeAndReturnKey(p).longValue();
        b.setBookId(id);
        return id;
    }

    public int update(Books b) {
        String sql = "UPDATE " + TABLE_NAME + " SET " +
                "title = ?, isbn = ?, publish_year = ?, description = ?, cover_image = ?, " +
                "language = ?, pages = ?, category_id = ?, author_id = ?, publisher_id = ? " +
                "WHERE book_id = ?";
        return jdbcTemplate.update(sql,
                b.getTitle(), b.getIsbn(), b.getPublishYear(), b.getDescription(),
                b.getCoverImage(), b.getLanguage(), b.getPages(),
                b.getCategoryId(), b.getAuthorId(), b.getPublisherId(), b.getBookId());
    }

    public int deleteById(long id) {
        return jdbcTemplate.update("DELETE FROM " + TABLE_NAME + " WHERE book_id = ?", id);
    }
}