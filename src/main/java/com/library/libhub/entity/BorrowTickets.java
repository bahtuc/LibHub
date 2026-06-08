package com.library.libhub.entity;


public class BorrowTickets {

  private long ticketId;
  private long userId;
  private java.sql.Date borrowDate;
  private java.sql.Date dueDate;
  private String status;
  private String note;
  private java.sql.Timestamp createdAt;


  public long getTicketId() {
    return ticketId;
  }

  public void setTicketId(long ticketId) {
    this.ticketId = ticketId;
  }


  public long getUserId() {
    return userId;
  }

  public void setUserId(long userId) {
    this.userId = userId;
  }


  public java.sql.Date getBorrowDate() {
    return borrowDate;
  }

  public void setBorrowDate(java.sql.Date borrowDate) {
    this.borrowDate = borrowDate;
  }


  public java.sql.Date getDueDate() {
    return dueDate;
  }

  public void setDueDate(java.sql.Date dueDate) {
    this.dueDate = dueDate;
  }


  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }


  public String getNote() {
    return note;
  }

  public void setNote(String note) {
    this.note = note;
  }


  public java.sql.Timestamp getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(java.sql.Timestamp createdAt) {
    this.createdAt = createdAt;
  }

}
