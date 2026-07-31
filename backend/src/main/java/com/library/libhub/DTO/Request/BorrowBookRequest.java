package com.library.libhub.DTO.Request;

import java.util.List;

public class BorrowBookRequest {

    private Long bookId;
    private List<Long> bookIds;

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
}
