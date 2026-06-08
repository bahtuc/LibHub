package com.library.libhub.entity;


public class Fines {

  private long fineId;
  private long returnDetailId;
  private double amount;
  private String reason;
  private String paidStatus;
  private java.sql.Timestamp createdAt;


  public long getFineId() {
    return fineId;
  }

  public void setFineId(long fineId) {
    this.fineId = fineId;
  }


  public long getReturnDetailId() {
    return returnDetailId;
  }

  public void setReturnDetailId(long returnDetailId) {
    this.returnDetailId = returnDetailId;
  }


  public double getAmount() {
    return amount;
  }

  public void setAmount(double amount) {
    this.amount = amount;
  }


  public String getReason() {
    return reason;
  }

  public void setReason(String reason) {
    this.reason = reason;
  }


  public String getPaidStatus() {
    return paidStatus;
  }

  public void setPaidStatus(String paidStatus) {
    this.paidStatus = paidStatus;
  }


  public java.sql.Timestamp getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(java.sql.Timestamp createdAt) {
    this.createdAt = createdAt;
  }

}
