package com.healthcare.model;

import java.sql.Date;
import java.sql.Timestamp;

public class PatientProfile {
    private int id;
    private int userId;
    private Date dateOfBirth;
    private String bloodGroup;
    private String phoneNumber;
    private String address;
    private String medicalHistory;
    private Timestamp updatedAt;

    // Default Constructor
    public PatientProfile() {}

    // Overloaded Constructor for updates
    public PatientProfile(int userId, Date dateOfBirth, String bloodGroup, String phoneNumber, String address, String medicalHistory) {
        this.userId = userId;
        this.dateOfBirth = dateOfBirth;
        this.bloodGroup = bloodGroup;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.medicalHistory = medicalHistory;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Date getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getMedicalHistory() { return medicalHistory; }
    public void setMedicalHistory(String medicalHistory) { this.medicalHistory = medicalHistory; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}