package com.healthcare.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.healthcare.model.User;
import com.healthcare.util.DBConnection;

public class UserDAOImpl implements UserDAO {

    @Override
    public boolean isUserExists(String username, String email) {
        // Updated to use 'full_name' instead of 'username'
        String sql = "SELECT user_id FROM users WHERE full_name = ? OR email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username.trim());
            ps.setString(2, email.trim());
            
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); 
            }
        } catch (SQLException e) {
            System.err.println("❌ Error checking if user exists:");
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean registerUser(User user) {
        // Updated column names to 'full_name' to match your database exactly
        String sql = "INSERT INTO users (full_name, password, email, role) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getUsername().trim()); // Maps to full_name
            ps.setString(2, user.getPassword().trim()); 
            ps.setString(3, user.getEmail().trim());
            ps.setString(4, user.getRole().toUpperCase().trim());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error during user database registration insert:");
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public User validateUser(String username, String password) {
        // Updated selection and where clause to match 'user_id' and 'full_name'
        String sql = "SELECT user_id, full_name, email, role FROM users WHERE full_name = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username.trim());
            ps.setString(2, password.trim());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    // Extracting data using your exact database column names
                    user.setId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    return user; 
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error validating user credentials:");
            e.printStackTrace();
        }
        return null; 
    }
}