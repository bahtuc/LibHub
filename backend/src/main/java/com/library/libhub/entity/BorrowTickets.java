package com.library.libhub.entity;

import jakarta.persistence.*;
import java.sql.Date;
import java.sql.Timestamp;

@Entity
@Table(name = "BorrowTickets")
public class BorrowTickets {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "ticket_id")
  private Long ticketId;

  @Column(name = "user_id")
  private Long userId;

  @Column(name = "borrow_date")
  private Date borrowDate;

  @Column(name = "due_date")
  private Date dueDate;

  @Column(name = "status")
  private String status;

  @Column(name = "note")
  private String note;

  @Column(name = "created_at")
  private Timestamp createdAt;


  public Long getTicketId() {
    return ticketId;
  }

  public void setTicketId(Long ticketId) {
    this.ticketId = ticketId;
  }


  public Long getUserId() {
    return userId;
  }

  public void setUserId(Long userId) {
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
