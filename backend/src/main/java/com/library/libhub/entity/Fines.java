package com.library.libhub.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Fines")
public class Fines {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "fine_id")
  private Long fineId;

  @Column(name = "return_detail_id")
  private Long returnDetailId;

  @Column(name = "amount", precision = 18, scale = 2)
  private BigDecimal amount;

  @Column(name = "reason")
  private String reason;

  @Column(name = "paid_status")
  private String paidStatus;

  @Column(name = "created_at")
  private Timestamp createdAt;


  public Long getFineId() {
    return fineId;
  }

  public void setFineId(Long fineId) {
    this.fineId = fineId;
  }


  public Long getReturnDetailId() {
    return returnDetailId;
  }

  public void setReturnDetailId(Long returnDetailId) {
    this.returnDetailId = returnDetailId;
  }


  public BigDecimal getAmount() {
    return amount;
  }

  public void setAmount(BigDecimal amount) {
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
