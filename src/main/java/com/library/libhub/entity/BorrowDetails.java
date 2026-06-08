package com.library.libhub.entity;


public class BorrowDetails {

  private long detailId;
  private long ticketId;
  private long copyId;
  private String borrowStatus;


  public long getDetailId() {
    return detailId;
  }

  public void setDetailId(long detailId) {
    this.detailId = detailId;
  }


  public long getTicketId() {
    return ticketId;
  }

  public void setTicketId(long ticketId) {
    this.ticketId = ticketId;
  }


  public long getCopyId() {
    return copyId;
  }

  public void setCopyId(long copyId) {
    this.copyId = copyId;
  }


  public String getBorrowStatus() {
    return borrowStatus;
  }

  public void setBorrowStatus(String borrowStatus) {
    this.borrowStatus = borrowStatus;
  }

}
