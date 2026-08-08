package com.library.libhub.DTO.Request;

import java.util.Date;
import java.util.List;

public class BorrowTicketRequest {

    private Long userId;
    private String guestName;
    private String guestPhone;
    private Date borrowDate;
    private Date dueDate;
    private String note;
    private List<Long> copyIds;
    
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
    public Date getBorrowDate() {
        return borrowDate;
    }
    public void setBorrowDate(Date borrowDate) {
        this.borrowDate = borrowDate;
    }
    public Date getDueDate() {
        return dueDate;
    }
    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }
    public String getNote() {
        return note;
    }
    public void setNote(String note) {
        this.note = note;
    }
    public List<Long> getCopyIds() {
        return copyIds;
    }
    public void setCopyIds(List<Long> copyIds) {
        this.copyIds = copyIds;
    }

    
}
