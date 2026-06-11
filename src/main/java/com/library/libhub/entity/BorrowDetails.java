package com.library.libhub.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "BorrowDetails")
public class BorrowDetails {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "detail_id")
  private Long detailId;

  @Column(name = "ticket_id")
  private Long ticketId;

  @Column(name = "copy_id")
  private Long copyId;

  @Column(name = "borrow_status")
  private String borrowStatus;


  public Long getDetailId() {
    return detailId;
  }

  public void setDetailId(Long detailId) {
    this.detailId = detailId;
  }


  public Long getTicketId() {
    return ticketId;
  }

  public void setTicketId(Long ticketId) {
    this.ticketId = ticketId;
  }


  public Long getCopyId() {
    return copyId;
  }

  public void setCopyId(Long copyId) {
    this.copyId = copyId;
  }


  public String getBorrowStatus() {
    return borrowStatus;
  }

  public void setBorrowStatus(String borrowStatus) {
    this.borrowStatus = borrowStatus;
  }

}
