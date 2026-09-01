package com.library.libhub.DTO.Request;

public class RenewBorrowTicketRequest {
    private Integer extensionDays;

    public Integer getExtensionDays() {
        return extensionDays;
    }

    public void setExtensionDays(Integer extensionDays) {
        this.extensionDays = extensionDays;
    }
}
