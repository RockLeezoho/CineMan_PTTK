package com.example.cineman.model;

import java.time.LocalDate;

public class Manager extends Staff{
    private LocalDate hireDate;

    public Manager(){
        super();
    }
    private void setHireDate (LocalDate hireDate) {
        this.hireDate = hireDate;
    }
    private String getHireDate() {
        return hireDate.toString();
    }

}
