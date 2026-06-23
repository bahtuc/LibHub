package com.library.libhub.DTO.Request;

public class ReturnBookRequest {

    private Long ticketId;
    private Long receivedBy;
    private String note;
    
    public Long getTicketId() {
        return ticketId;
    }
    public void setTicketId(Long ticketId) {
        this.ticketId = ticketId;
    }
    public Long getReceivedBy() {
        return receivedBy;
    }
    public void setReceivedBy(Long receivedBy) {
        this.receivedBy = receivedBy;
    }
    public String getNote() {
        return note;
    }
    public void setNote(String note) {
        this.note = note;
    }

}
