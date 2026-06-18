package com.library.libhub.entity;

import jakarta.persistence.*;
import java.sql.Date;

@Entity
@Table(name = "BookCopies")
public class BookCopies {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "copy_id")
  private Long copyId;

  @Column(name = "book_id")
  private Long bookId;

  @Column(name = "barcode")
  private String barcode;

  @Column(name = "shelf_location")
  private String shelfLocation;

  @Column(name = "status")
  private String status;

  @Column(name = "acquired_date")
  private Date acquiredDate;


  public Long getCopyId() {
    return copyId;
  }

  public void setCopyId(Long copyId) {
    this.copyId = copyId;
  }


  public Long getBookId() {
    return bookId;
  }

  public void setBookId(Long bookId) {
    this.bookId = bookId;
  }


  public String getBarcode() {
    return barcode;
  }

  public void setBarcode(String barcode) {
    this.barcode = barcode;
  }


  public String getShelfLocation() {
    return shelfLocation;
  }

  public void setShelfLocation(String shelfLocation) {
    this.shelfLocation = shelfLocation;
  }


  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }


  public java.sql.Date getAcquiredDate() {
    return acquiredDate;
  }

  public void setAcquiredDate(java.sql.Date acquiredDate) {
    this.acquiredDate = acquiredDate;
  }

}
