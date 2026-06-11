package com.library.libhub.entity;

import jakarta.persistence.*;
import java.sql.Date;

@Entity
@Table(name = "Returns")
public class Returns {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "return_id")
  private Long returnId;

  @Column(name = "ticket_id")
  private Long ticketId;

  @Column(name = "return_date")
  private Date returnDate;

  @Column(name = "received_by")
  private Long receivedBy;

  @Column(name = "note")
  private String note;


  public Long getReturnId() {
    return returnId;
  }

  public void setReturnId(Long returnId) {
    this.returnId = returnId;
  }


  public Long getTicketId() {
    return ticketId;
  }

  public void setTicketId(Long ticketId) {
    this.ticketId = ticketId;
  }


  public java.sql.Date getReturnDate() {
    return returnDate;
  }

  public void setReturnDate(java.sql.Date returnDate) {
    this.returnDate = returnDate;
  }


  public Long getReceivedBy() {
    return receivedBy;
  }

  public void setReceivedBy(Long receivedBy) {
    this.receivedBy = receivedBy;
  }


  public String getNote() {
    return note;
  }

  public void setNote(String note) {
    this.note = note;
  }

}
