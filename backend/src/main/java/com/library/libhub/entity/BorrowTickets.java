package com.library.libhub.entity;

import jakarta.persistence.*;
import java.sql.Date;
import java.sql.Timestamp;
import java.math.BigDecimal;

@Entity
@Table(name = "BorrowTickets")
public class BorrowTickets {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "ticket_id")
  private Long ticketId;

  @Column(name = "user_id")
  private Long userId;

  @Column(name = "guest_name")
  private String guestName;

  @Column(name = "guest_phone")
  private String guestPhone;

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

  @Column(name = "deposit_amount", precision = 18, scale = 2)
  private BigDecimal depositAmount;

  @Column(name = "deposit_paid_status")
  private String depositPaidStatus;


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

  public String getGuestName() {
    return guestName;
  }

  public void setGuestName(String guestName) {
    this.guestName = guestName;
  }

  public String getGuestPhone() {
    return guestPhone;
  }

  public void setGuestPhone(String guestPhone) {
    this.guestPhone = guestPhone;
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

  public BigDecimal getDepositAmount() { return depositAmount; }
  public void setDepositAmount(BigDecimal depositAmount) { this.depositAmount = depositAmount; }
  public String getDepositPaidStatus() { return depositPaidStatus; }
  public void setDepositPaidStatus(String depositPaidStatus) { this.depositPaidStatus = depositPaidStatus; }

}
