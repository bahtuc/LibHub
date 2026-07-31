package com.library.libhub.DTO.Response;

import java.sql.Date;
import java.util.List;

public class BorrowTicketResponse {

    private Long ticketId;
    private Long userId;
    private String userName;
    private Date borrowDate;
    private Date dueDate;
    private String status;
    private String note;
    private List<BorrowedItemResponse> items;

    public Long getTicketId() {
        return ticketId;
    }

    public void setTicketId(Long ticketId) {
        this.ticketId = ticketId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public List<BorrowedItemResponse> getItems() {
        return items;
    }

    public void setItems(List<BorrowedItemResponse> items) {
        this.items = items;
    }
}
