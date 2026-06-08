package com.library.libhub.entity;


public class Returns {

  private long returnId;
  private long ticketId;
  private java.sql.Date returnDate;
  private long receivedBy;
  private String note;


  public long getReturnId() {
    return returnId;
  }

  public void setReturnId(long returnId) {
    this.returnId = returnId;
  }


  public long getTicketId() {
    return ticketId;
  }

  public void setTicketId(long ticketId) {
    this.ticketId = ticketId;
  }


  public java.sql.Date getReturnDate() {
    return returnDate;
  }

  public void setReturnDate(java.sql.Date returnDate) {
    this.returnDate = returnDate;
  }


  public long getReceivedBy() {
    return receivedBy;
  }

  public void setReceivedBy(long receivedBy) {
    this.receivedBy = receivedBy;
  }


  public String getNote() {
    return note;
  }

  public void setNote(String note) {
    this.note = note;
  }

}
