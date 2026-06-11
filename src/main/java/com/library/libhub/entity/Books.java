package com.library.libhub.entity;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "Books")
public class Books {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "book_id")
  private Long bookId;

  @Column(name = "title")
  private String title;

  @Column(name = "isbn")
  private String isbn;

  @Column(name = "publish_year")
  private Long publishYear;

  @Column(name = "description")
  private String description;

  @Column(name = "cover_image")
  private String coverImage;

  @Column(name = "language")
  private String language;

  @Column(name = "pages")
  private Long pages;

  @Column(name = "category_id")
  private Long categoryId;

  @Column(name = "author_id")
  private Long authorId;

  @Column(name = "publisher_id")
  private Long publisherId;

  @Column(name = "created_at")
  private Timestamp createdAt;


  public Long getBookId() {
    return bookId;
  }

  public void setBookId(Long bookId) {
    this.bookId = bookId;
  }


  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }


  public String getIsbn() {
    return isbn;
  }

  public void setIsbn(String isbn) {
    this.isbn = isbn;
  }


  public Long getPublishYear() {
    return publishYear;
  }

  public void setPublishYear(Long publishYear) {
    this.publishYear = publishYear;
  }


  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }


  public String getCoverImage() {
    return coverImage;
  }

  public void setCoverImage(String coverImage) {
    this.coverImage = coverImage;
  }


  public String getLanguage() {
    return language;
  }

  public void setLanguage(String language) {
    this.language = language;
  }


  public Long getPages() {
    return pages;
  }

  public void setPages(Long pages) {
    this.pages = pages;
  }


  public Long getCategoryId() {
    return categoryId;
  }

  public void setCategoryId(Long categoryId) {
    this.categoryId = categoryId;
  }


  public Long getAuthorId() {
    return authorId;
  }

  public void setAuthorId(Long authorId) {
    this.authorId = authorId;
  }


  public Long getPublisherId() {
    return publisherId;
  }

  public void setPublisherId(Long publisherId) {
    this.publisherId = publisherId;
  }


  public Timestamp getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(Timestamp createdAt) {
    this.createdAt = createdAt;
  }

}
