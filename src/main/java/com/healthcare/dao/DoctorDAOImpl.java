package com.healthcare.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.healthcare.model.User;
import com.healthcare.util.DBConnection;

public class DoctorDAOImpl {

    // Simple inner wrapper class to hold combined User and Doctor table rows cleanly
    public static class DoctorProfile {
        private int doctorId;
        private String fullName;
        private String specialization;

        public int getDoctorId() { return doctorId; }
        public void setDoctorId(int doctorId) { this.doctorId = doctorId; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getSpecialization() { return specialization; }
        public void setSpecialization(String specialization) { this.specialization = specialization; }
    }

    public List<DoctorProfile> getAllActiveDoctors() {
        List<DoctorProfile> list = new ArrayList<>();
        // Matches your exact tables: users (user_id, full_name) and doctors (doctor_id, user_id, specialization)
        String sql = "SELECT d.doctor_id, u.full_name, d.specialization " +
                     "FROM doctors d " +
                     "JOIN users u ON d.user_id = u.user_id " +
                     "WHERE u.is_active = 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DoctorProfile profile = new DoctorProfile();
                profile.setDoctorId(rs.getInt("doctor_id"));
                profile.setFullName(rs.getString("full_name"));
                profile.setSpecialization(rs.getString("specialization"));
                list.add(profile);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error retrieving listings from doctors table join configuration:");
            e.printStackTrace();
        }
        return list;
    }
}