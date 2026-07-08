package com.healthcare.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.healthcare.util.DBConnection;

public class AdminDAO {

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

    public boolean toggleUserStatus(int userId, boolean currentStatus) {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, !currentStatus);
            ps.setInt(2, userId);
            
            // Log the action dynamically
            logAdminAction("SYSTEM", "TOGGLE_USER_STATUS", "Altered active state for user ID: " + userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            logAdminAction("SYSTEM", "DELETE_USER", "Permanently purged user account ID: " + userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Upgraded robust synchronization logic
 // Upgraded robust synchronization logic supporting your custom schema attributes
    public boolean provisionDoctorProfile(int userId, String specialization) {
        String checkSql = "SELECT doctor_id FROM doctors WHERE user_id = ?";
        // Added consultation_fee to satisfy the strict NOT NULL database rule
        String insertSql = "INSERT INTO doctors (user_id, specialization, consultation_fee) VALUES (?, ?, ?)";
        String updateSql = "UPDATE doctors SET specialization = ? WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, userId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        // Profile exists already, updating specialization is unaffected
                        try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                            updatePs.setString(1, specialization.trim());
                            updatePs.setInt(2, userId);
                            logAdminAction("SYSTEM", "UPDATE_DOCTOR_SPEC", "Updated specialization to " + specialization + " for user ID: " + userId);
                            return updatePs.executeUpdate() > 0;
                        }
                    } else {
                        // Profile missing, inserting with a safe baseline consultation fee (e.g., 0.0)
                        try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                            insertPs.setInt(1, userId);
                            insertPs.setString(2, specialization.trim());
                            insertPs.setDouble(3, 0.0); // Safe baseline value. The doctor can update this later from their dashboard profile settings!
                            
                            logAdminAction("SYSTEM", "PROVISION_DOCTOR", "Created doctor profile with specialization " + specialization + " for user ID: " + userId);
                            return insertPs.executeUpdate() > 0;
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("🔥 Database Error Provisioning Doctor Profile Schema: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Fetch Simulated system configurations safely (Memory persistent fallback context)
    public Map<String, String> getSystemConfigurations() {
        Map<String, String> configs = new HashMap<>();
        configs.put("maintenance_mode", "FALSE");
        configs.put("allow_registrations", "TRUE");
        configs.put("ai_consultation_limit", "50");
        configs.put("session_timeout_min", "30");
        
        String sql = "SELECT config_key, config_value FROM system_config";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                configs.put(rs.getString("config_key"), rs.getString("config_value"));
            }
        } catch (SQLException e) {
            // Table doesn't exist yet, gracefully use defaults
        }
        return configs;
    }

    public boolean updateConfig(String key, String value) {
        // Build table if missing dynamically, then save values
        String createTableSql = "CREATE TABLE IF NOT EXISTS system_config (config_key VARCHAR(100) PRIMARY KEY, config_value VARCHAR(255))";
        String saveSql = "INSERT INTO system_config (config_key, config_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE config_value = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (Statement stmt = conn.createStatement()) { stmt.execute(createTableSql); }
            try (PreparedStatement ps = conn.prepareStatement(saveSql)) {
                ps.setString(1, key);
                ps.setString(2, value);
                ps.setString(3, value);
                logAdminAction("SYSTEM", "UPDATE_CONFIG", "Modified config attribute " + key + " to " + value);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Dynamic Audit Log Tracking System Engine
    public List<Map<String, String>> getAuditTrackingLogs() {
        List<Map<String, String>> logs = new ArrayList<>();
        String createTableSql = "CREATE TABLE IF NOT EXISTS audit_logs (id INT AUTO_INCREMENT PRIMARY KEY, actor VARCHAR(100), action VARCHAR(100), details TEXT, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
        String selectSql = "SELECT actor, action, details, timestamp FROM audit_logs ORDER BY id DESC LIMIT 100";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (Statement stmt = conn.createStatement()) { stmt.execute(createTableSql); }
            try (PreparedStatement ps = conn.prepareStatement(selectSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> log = new HashMap<>();
                    log.put("actor", rs.getString("actor"));
                    log.put("action", rs.getString("action"));
                    log.put("details", rs.getString("details"));
                    log.put("timestamp", rs.getTimestamp("timestamp").toString());
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }

    private void logAdminAction(String actor, String action, String details) {
        String insertSql = "INSERT INTO audit_logs (actor, action, details) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setString(1, actor);
            ps.setString(2, action);
            ps.setString(3, details);
            ps.executeUpdate();
        } catch (SQLException e) {
            // Suppress secondary logging issues
        }
    }
}