package com.library.libhub.entity;


public class BookCopies {

  private long copyId;
  private long bookId;
  private String barcode;
  private String shelfLocation;
  private String status;
  private java.sql.Date acquiredDate;


  public long getCopyId() {
    return copyId;
  }

  public void setCopyId(long copyId) {
    this.copyId = copyId;
  }


  public long getBookId() {
    return bookId;
  }

  public void setBookId(long bookId) {
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
