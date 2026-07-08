package com.healthcare.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.healthcare.util.DBConnection;

public class AdminDAO {

    // Fetch all registered users in the system along with any doctor specialization info
    public List<Map<String, Object>> getAllUsersWithDetails() {
        List<Map<String, Object>> userList = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.email, u.role, u.is_active, d.specialization, d.doctor_id " +
                     "FROM users u " +
                     "LEFT JOIN doctors d ON u.user_id = d.user_id " +
                     "ORDER BY u.user_id DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("userId", rs.getInt("user_id"));
                row.put("fullName", rs.getString("full_name"));
                row.put("email", rs.getString("email"));
                row.put("role", rs.getString("role"));
                row.put("isActive", rs.getBoolean("is_active"));
                row.put("specialization", rs.getString("specialization"));
                row.put("doctorId", rs.getInt("doctor_id"));
                userList.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return userList;
    }

    // Toggle user operational status (Activate/Deactivate)
    public boolean toggleUserStatus(int userId, boolean currentStatus) {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, !currentStatus);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Permanently remove a user account from registry
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Link or upgrade a user into the doctors lookup directory table
    public boolean provisionDoctorProfile(int userId, String specialization) {
        // Check if doctor profile record already exists first
        String checkSql = "SELECT doctor_id FROM doctors WHERE user_id = ?";
        String insertSql = "INSERT INTO doctors (user_id, specialization) VALUES (?, ?)";
        String updateSql = "UPDATE doctors SET specialization = ? WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            // 1. Verify existence
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, userId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        // Profile exists, update specialization field
                        try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                            updatePs.setString(1, specialization.trim());
                            updatePs.setInt(2, userId);
                            return updatePs.executeUpdate() > 0;
                        }
                    } else {
                        // Profile missing, execute insertion link
                        try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                            insertPs.setInt(1, userId);
                            insertPs.setString(2, specialization.trim());
                            return insertPs.executeUpdate() > 0;
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}