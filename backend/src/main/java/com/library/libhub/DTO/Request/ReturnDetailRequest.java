package com.library.libhub.DTO.Request;


public class ReturnDetailRequest {

    private Long copyId;
    private String conditionBook;

    public Long getCopyId() {
        return copyId;
    }

    public void setCopyId(Long copyId) {
        this.copyId = copyId;
    }

    public String getConditionBook() {
        return conditionBook;
    }

    public void setConditionBook(String conditionBook) {
        this.conditionBook = conditionBook;
    }

}
