package com.library.libhub.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "Publishers")
public class Publishers {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "publisher_id")
  private Long publisherId;

  @Column(name = "publisher_name")
  private String publisherName;

  @Column(name = "address")
  private String address;

  @Column(name = "phone")
  private String phone;


  public Long getPublisherId() {
    return publisherId;
  }

  public void setPublisherId(Long publisherId) {
    this.publisherId = publisherId;
  }


  public String getPublisherName() {
    return publisherName;
  }

  public void setPublisherName(String publisherName) {
    this.publisherName = publisherName;
  }


  public String getAddress() {
    return address;
  }

  public void setAddress(String address) {
    this.address = address;
  }


  public String getPhone() {
    return phone;
  }

  public void setPhone(String phone) {
    this.phone = phone;
  }

}
