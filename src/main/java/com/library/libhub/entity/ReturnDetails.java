package com.library.libhub.entity;


public class ReturnDetails {

  private long returnDetailId;
  private long returnId;
  private long copyId;
  private String conditionBook;


  public long getReturnDetailId() {
    return returnDetailId;
  }

  public void setReturnDetailId(long returnDetailId) {
    this.returnDetailId = returnDetailId;
  }


  public long getReturnId() {
    return returnId;
  }

  public void setReturnId(long returnId) {
    this.returnId = returnId;
  }


  public long getCopyId() {
    return copyId;
  }

  public void setCopyId(long copyId) {
    this.copyId = copyId;
  }


  public String getConditionBook() {
    return conditionBook;
  }

  public void setConditionBook(String conditionBook) {
    this.conditionBook = conditionBook;
  }

}
