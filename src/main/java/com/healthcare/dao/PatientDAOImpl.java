package com.healthcare.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.healthcare.model.PatientProfile;
import com.healthcare.util.DBConnection; // Assuming your DB connection helper is here

public class PatientDAOImpl implements PatientDAO {

    @Override
    public PatientProfile getProfileByUserId(int userId) {
        String sql = "SELECT * FROM patient_profiles WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PatientProfile profile = new PatientProfile();
                    profile.setId(rs.getInt("id"));
                    profile.setUserId(rs.getInt("user_id"));
                    profile.setDateOfBirth(rs.getDate("date_of_birth"));
                    profile.setBloodGroup(rs.getString("blood_group"));
                    profile.setPhoneNumber(rs.getString("phone_number"));
                    profile.setAddress(rs.getString("address"));
                    profile.setMedicalHistory(rs.getString("medical_history"));
                    profile.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return profile;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // Returns null if no profile exists yet
    }

    @Override
    public boolean saveOrUpdateProfile(PatientProfile profile) {
        // This upsert query inserts a record if it doesn't exist, or updates it if it does
        String sql = "INSERT INTO patient_profiles (user_id, date_of_birth, blood_group, phone_number, address, medical_history) " +
                     "VALUES (?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "date_of_birth = ?, blood_group = ?, phone_number = ?, address = ?, medical_history = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            // Bind insert parameters
            ps.setInt(1, profile.getUserId());
            ps.setDate(2, profile.getDateOfBirth());
            ps.setString(3, profile.getBloodGroup());
            ps.setString(4, profile.getPhoneNumber());
            ps.setString(5, profile.getAddress());
            ps.setString(6, profile.getMedicalHistory());
            
            // Bind update parameters
            ps.setDate(7, profile.getDateOfBirth());
            ps.setString(8, profile.getBloodGroup());
            ps.setString(9, profile.getPhoneNumber());
            ps.setString(10, profile.getAddress());
            ps.setString(11, profile.getMedicalHistory());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}