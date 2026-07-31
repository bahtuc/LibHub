package com.library.libhub.entity;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "PaymentTransactions",
        uniqueConstraints = @UniqueConstraint(name = "uk_payment_txn_ref", columnNames = "txn_ref"))
public class PaymentTransactions {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "payment_id")
    private Long paymentId;
    @Column(name = "fine_id", nullable = false)
    private Long fineId;
    @Column(name = "user_id", nullable = false)
    private Long userId;
    @Column(name = "txn_ref", nullable = false, length = 100)
    private String txnRef;
    @Column(name = "amount", nullable = false)
    private Long amount;
    @Column(name = "status", nullable = false, length = 30)
    private String status;
    @Column(name = "bank_transaction_no", length = 100)
    private String bankTransactionNo;
    @Column(name = "created_at", nullable = false)
    private Timestamp createdAt;
    @Column(name = "updated_at")
    private Timestamp updatedAt;

    public Long getPaymentId() { return paymentId; }
    public void setPaymentId(Long paymentId) { this.paymentId = paymentId; }
    public Long getFineId() { return fineId; }
    public void setFineId(Long fineId) { this.fineId = fineId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getTxnRef() { return txnRef; }
    public void setTxnRef(String txnRef) { this.txnRef = txnRef; }
    public Long getAmount() { return amount; }
    public void setAmount(Long amount) { this.amount = amount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getBankTransactionNo() { return bankTransactionNo; }
    public void setBankTransactionNo(String bankTransactionNo) { this.bankTransactionNo = bankTransactionNo; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
