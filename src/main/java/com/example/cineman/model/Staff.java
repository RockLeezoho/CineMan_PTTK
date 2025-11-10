package com.example.cineman.model;

public class Staff extends SystemUser{
    private String position;
    private String address;

    public Staff(){
        super();
    }
    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }
}
