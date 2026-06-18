package com.library.libhub.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "ReturnDetails")
public class ReturnDetails {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "return_detail_id")
  private Long returnDetailId;

  @Column(name = "return_id")
  private Long returnId;

  @Column(name = "copy_id")
  private Long copyId;

  @Column(name = "condition_book")
  private String conditionBook;


  public Long getReturnDetailId() {
    return returnDetailId;
  }

  public void setReturnDetailId(Long returnDetailId) {
    this.returnDetailId = returnDetailId;
  }


  public Long getReturnId() {
    return returnId;
  }

  public void setReturnId(Long returnId) {
    this.returnId = returnId;
  }


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
