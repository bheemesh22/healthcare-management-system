package com.healthcare.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.healthcare.util.DBConnection;

public class DoctorDAO {

    // Fetch details of a doctor using their core user_id session key
    public Map<String, Object> getDoctorProfileByUserId(int userId) {
        Map<String, Object> profile = new HashMap<>();
        String sql = "SELECT doctor_id, specialization, consultation_fee, available_hours FROM doctors WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    profile.put("doctorId", rs.getInt("doctor_id"));
                    profile.put("specialization", rs.getString("specialization"));
                    profile.put("consultationFee", rs.getDouble("consultation_fee"));
                    profile.put("availabilityHours", rs.getString("available_hours"));
                }
            }
        } catch (SQLException e) {
            System.err.println("🔥 Error reading doctor profile parameters: " + e.getMessage());
            e.printStackTrace();
        }
        return profile;
    }

    // Update doctor professional workspace settings
    public boolean updateDoctorProfile(int userId, double fee, String hours) {
        String sql = "UPDATE doctors SET consultation_fee = ?, available_hours = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, fee);
            ps.setString(2, hours.trim());
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("🔥 Profile Sync completely blocked: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Fetch all appointment records booked with this specific doctor (Symptoms Updated)
    public List<Map<String, Object>> getDoctorAppointments(int doctorId) {
        List<Map<String, Object>> appointments = new ArrayList<>();
        // SECURED: Explicit selection of a.symptoms from the appointments schema
        String sql = "SELECT a.appointment_id, a.appointment_date, a.symptoms, a.status, u.full_name AS patient_name " +
                     "FROM appointments a " +
                     "JOIN patients p ON a.patient_id = p.patient_id " +
                     "JOIN users u ON p.user_id = u.user_id " +
                     "WHERE a.doctor_id = ? " +
                     "ORDER BY a.appointment_date ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> app = new HashMap<>();
                    app.put("appointmentId", rs.getInt("appointment_id"));
                    
                    Timestamp ts = rs.getTimestamp("appointment_date");
                    if (ts != null) {
                        app.put("date", ts.toLocalDateTime().toLocalDate().toString());
                        app.put("time", ts.toLocalDateTime().toLocalTime().toString());
                    } else {
                        app.put("date", "N/A");
                        app.put("time", "N/A");
                    }
                    
                    // EXTRACTED: Read the text field safely and supply default strings if null
                    String rawSymptoms = rs.getString("symptoms");
                    app.put("symptoms", (rawSymptoms != null && !rawSymptoms.trim().isEmpty()) ? rawSymptoms : "No specific symptoms logged by patient.");
                    
                    app.put("status", rs.getString("status"));
                    app.put("patientName", rs.getString("patient_name"));
                    appointments.add(app);
                }
            }
        } catch (SQLException e) {
            System.err.println("🔥 Error indexing appointment maps: " + e.getMessage());
            e.printStackTrace();
        }
        return appointments;
    }

    // Accept or reject a patient appointment request
    public boolean updateAppointmentStatus(int appointmentId, String newStatus) {
        String sql = "UPDATE appointments SET status = ? WHERE appointment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}