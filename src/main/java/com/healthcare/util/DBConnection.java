package com.healthcare.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Corrected to the default standard MySQL port 3306
    private static final String URL = "jdbc:mysql://localhost:3306/healthcare_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "@Bheemesh123"; 

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Failed to find MySQL JDBC Driver jar dependency!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        // Dynamically allocates a fresh live socket pipeline connection
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}