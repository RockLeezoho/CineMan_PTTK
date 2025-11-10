package com.example.cineman.model;

public class Seat {
    private int id;
    private String seatRow;
    private String seatColumn;
    private String seatType;
    private float dynamicPrice;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSeatRow() {
        return seatRow;
    }

    public void setSeatRow(String seatRow) {
        this.seatRow = seatRow;
    }

    public String getSeatColumn() {
        return seatColumn;
    }

    public void setSeatColumn(String seatColumn) {
        this.seatColumn = seatColumn;
    }

    public String getSeatType() {
        return seatType;
    }

    public void setSeatType(String seatType) {
        this.seatType = seatType;
    }

    public float getDynamicPrice() {
        return dynamicPrice;
    }

    public void setDynamicPrice(float dynamicPrice) {
        this.dynamicPrice = dynamicPrice;
    }
}
