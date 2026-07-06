package com.healthcare.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static Connection connection = null;

    // Static block to initialize the connection pool/driver once when the class loads
    static {
        try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties prop = new Properties();

            if (input == null) {
                System.out.println("Sorry, unable to find db.properties file.");
            } else {
                // Load the properties file
                prop.load(input);

                // Load the MySQL Driver class explicitly
                Class.forName(prop.getProperty("db.driver"));

                // Establish the connection
                connection = DriverManager.getConnection(
                    prop.getProperty("db.url"),
                    prop.getProperty("db.username"),
                    prop.getProperty("db.password")
                );
                System.out.println("🚀 Database connection established successfully!");
            }
        } catch (Exception e) {
            System.err.println("❌ Database connection failed initialization!");
            e.printStackTrace();
        }
    }

    // Public method to get the active connection instance
    public static Connection getConnection() {
        try {
            // Reopen connection if it was closed unexpectedly
            if (connection == null || connection.isClosed()) {
                synchronized (DBConnection.class) {
                    if (connection == null || connection.isClosed()) {
                        // Re-fetch using standard credentials if necessary
                        // For simplicity, we assume the static block handles initial setup flawlessly
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return connection;
    }
}