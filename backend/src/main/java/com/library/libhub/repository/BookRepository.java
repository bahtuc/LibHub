package com.library.libhub.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.library.libhub.entity.Books;

@Repository
public interface BookRepository extends JpaRepository<Books, Long> {

    Optional<Books> findByIsbn(String isbn);
    @Query("""
            SELECT b FROM Books b
            WHERE b.isbn = :isbn
              AND (b.hidden = false OR b.hidden IS NULL)
            """)
    Optional<Books> findByIsbnAndHiddenFalse(@Param("isbn") String isbn);

    List<Books> findByCategoryId(long categoryId);

    List<Books> findByAuthorId(long authorId);

    List<Books> findByTitleContainingIgnoreCase(String keyword);

    Page<Books> findByTitleContainingIgnoreCase(String keyword, Pageable pageable);

    @Query("""
            SELECT b FROM Books b
            WHERE b.hidden = false OR b.hidden IS NULL
            """)
    Page<Books> findByHiddenFalse(Pageable pageable);
    @Query("SELECT b FROM Books b WHERE b.hidden = false OR b.hidden IS NULL ORDER BY b.title")
    List<Books> findAllVisible();

    @Query("""
            SELECT b FROM Books b
            WHERE (b.hidden = false OR b.hidden IS NULL)
              AND LOWER(b.title) LIKE LOWER(CONCAT('%', :keyword, '%'))
            """)
    Page<Books> findByHiddenFalseAndTitleContainingIgnoreCase(
            @Param("keyword") String keyword,
            Pageable pageable);

    @Query("""
            SELECT b FROM Books b
            WHERE b.bookId = :bookId
              AND (b.hidden = false OR b.hidden IS NULL)
            """)
    Optional<Books> findByBookIdAndHiddenFalse(@Param("bookId") long bookId);

    @Query("""
            SELECT b FROM Books b
            WHERE b.categoryId = :categoryId
              AND (b.hidden = false OR b.hidden IS NULL)
            """)
    List<Books> findByCategoryIdAndHiddenFalse(@Param("categoryId") long categoryId);

    @Query("""
            SELECT b FROM Books b
            WHERE b.authorId = :authorId
              AND (b.hidden = false OR b.hidden IS NULL)
            """)
    List<Books> findByAuthorIdAndHiddenFalse(@Param("authorId") long authorId);

    @Query("""
            SELECT b FROM Books b
            WHERE (b.hidden = false OR b.hidden IS NULL)
              AND LOWER(b.title) LIKE LOWER(CONCAT('%', :keyword, '%'))
            """)
    List<Books> findByTitleContainingIgnoreCaseAndHiddenFalse(@Param("keyword") String keyword);

    @Query("""
            SELECT b FROM Books b
            WHERE (b.hidden = false OR b.hidden IS NULL) AND (
              LOWER(b.title) LIKE LOWER(CONCAT('%', :keyword, '%'))
              OR LOWER(COALESCE(b.isbn, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
              OR b.authorId IN (
                  SELECT a.authorId FROM Authors a
                  WHERE LOWER(a.authorName) LIKE LOWER(CONCAT('%', :keyword, '%')))
              OR b.publisherId IN (
                  SELECT p.publisherId FROM Publishers p
                  WHERE LOWER(p.publisherName) LIKE LOWER(CONCAT('%', :keyword, '%')))
            )
            """)
    Page<Books> searchVisible(@Param("keyword") String keyword, Pageable pageable);

    @Query("""
            SELECT b FROM Books b
            WHERE (b.hidden = false OR b.hidden IS NULL) AND (
              LOWER(b.title) LIKE LOWER(CONCAT('%', :keyword, '%'))
              OR LOWER(COALESCE(b.isbn, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
              OR b.authorId IN (
                  SELECT a.authorId FROM Authors a
                  WHERE LOWER(a.authorName) LIKE LOWER(CONCAT('%', :keyword, '%')))
              OR b.publisherId IN (
                  SELECT p.publisherId FROM Publishers p
                  WHERE LOWER(p.publisherName) LIKE LOWER(CONCAT('%', :keyword, '%')))
            )
            ORDER BY b.title
            """)
    List<Books> searchVisible(@Param("keyword") String keyword);
}
