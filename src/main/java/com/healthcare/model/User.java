package com.healthcare.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String email;
    private String password;
    private String role; // ADMIN, DOCTOR, PATIENT
    private Timestamp createdAt;

    // Default Constructor
    public User() {}

    // Constructor for Registration
    public User(String username, String email, String password, String role) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    // --- ALIAS METHODS TO MATCH DATABASE SCHEMAS AND LOGIN SERVLET ---
    
    public int getUserId() { 
        return this.id; 
    }
    public void setUserId(int userId) { 
        this.id = userId; 
    }

    public String getFullName() { 
        return this.username; 
    }
    public void setFullName(String fullName) { 
        this.username = fullName; 
    }

    public boolean isActive() { 
        return true; // Simple default fallback since tinyint(1) defaults to active
    }
    public void setActive(boolean isActive) {
        // Keeps login servlet signature satisfied cleanly
    }

    // --- YOUR ORIGINAL GETTERS AND SETTERS ---

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}