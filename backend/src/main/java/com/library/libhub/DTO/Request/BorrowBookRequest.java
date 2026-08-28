package com.library.libhub.DTO.Request;

import java.util.List;

public class BorrowBookRequest {

    private Long bookId;
    private List<Long> bookIds;
    private Boolean paymentConfirmed;
    private Integer borrowDays;

    public Long getBookId() {
        return bookId;
    }

    public void setBookId(Long bookId) {
        this.bookId = bookId;
    }

    public List<Long> getBookIds() {
        return bookIds;
    }

    public void setBookIds(List<Long> bookIds) {
        this.bookIds = bookIds;
    }

    public Boolean getPaymentConfirmed() { return paymentConfirmed; }
    public void setPaymentConfirmed(Boolean paymentConfirmed) { this.paymentConfirmed = paymentConfirmed; }

    public Integer getBorrowDays() { return borrowDays; }
    public void setBorrowDays(Integer borrowDays) { this.borrowDays = borrowDays; }
}
