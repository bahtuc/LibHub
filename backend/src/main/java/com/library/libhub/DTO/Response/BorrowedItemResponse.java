package com.library.libhub.DTO.Response;

import java.math.BigDecimal;
import java.sql.Date;

public class BorrowedItemResponse {
    private Long detailId;
    private Long copyId;
    private Long bookId;
    private String bookTitle;
    private String barcode;
    private String borrowStatus;
    private Date borrowDate;
    private Date dueDate;
    private Date returnedDate;
    private String conditionBook;
    private Long returnDetailId;
    private Long fineId;
    private BigDecimal fineAmount;
    private String fineReason;
    private String finePaidStatus;

    public Long getDetailId() { return detailId; }
    public void setDetailId(Long detailId) { this.detailId = detailId; }
    public Long getCopyId() { return copyId; }
    public void setCopyId(Long copyId) { this.copyId = copyId; }
    public Long getBookId() { return bookId; }
    public void setBookId(Long bookId) { this.bookId = bookId; }
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }
    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }
    public String getBorrowStatus() { return borrowStatus; }
    public void setBorrowStatus(String borrowStatus) { this.borrowStatus = borrowStatus; }
    public Date getBorrowDate() { return borrowDate; }
    public void setBorrowDate(Date borrowDate) { this.borrowDate = borrowDate; }
    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    public Date getReturnedDate() { return returnedDate; }
    public void setReturnedDate(Date returnedDate) { this.returnedDate = returnedDate; }
    public String getConditionBook() { return conditionBook; }
    public void setConditionBook(String conditionBook) { this.conditionBook = conditionBook; }
    public Long getReturnDetailId() { return returnDetailId; }
    public void setReturnDetailId(Long returnDetailId) { this.returnDetailId = returnDetailId; }
    public Long getFineId() { return fineId; }
    public void setFineId(Long fineId) { this.fineId = fineId; }
    public BigDecimal getFineAmount() { return fineAmount; }
    public void setFineAmount(BigDecimal fineAmount) { this.fineAmount = fineAmount; }
    public String getFineReason() { return fineReason; }
    public void setFineReason(String fineReason) { this.fineReason = fineReason; }
    public String getFinePaidStatus() { return finePaidStatus; }
    public void setFinePaidStatus(String finePaidStatus) { this.finePaidStatus = finePaidStatus; }
}
