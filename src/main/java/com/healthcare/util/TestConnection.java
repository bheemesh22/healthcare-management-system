package com.healthcare.util;

import java.sql.Connection;

public class TestConnection {

    public static void main(String[] args) {
        System.out.println("🔄 Testing database connectivity...");
        
        // Call the getConnection method from our utility class
        Connection conn = DBConnection.getConnection();
        
        if (conn != null) {
            System.out.println("✅ SUCCESS: Your backend can successfully talk to MySQL!");
        } else {
            System.err.println("❌ FAILURE: Connection object is null. Please double-check your db.properties details and ensure MySQL Server is running.");
        }
    }
}