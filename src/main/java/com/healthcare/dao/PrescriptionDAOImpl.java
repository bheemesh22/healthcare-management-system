package com.healthcare.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import com.healthcare.model.Prescription;
import com.healthcare.util.DBConnection;

public class PrescriptionDAOImpl {

    // Saves a new prescription record linked directly to a verified appointment_id
    public boolean addPrescription(Prescription prescription) {
        String sql = "INSERT INTO prescriptions (appointment_id, diagnosis, doctor_notes, prescribed_medicines) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, prescription.getAppointmentId());
            ps.setString(2, prescription.getDiagnosis().trim());
            ps.setString(3, prescription.getDoctorNotes() != null ? prescription.getDoctorNotes().trim() : "");
            ps.setString(4, prescription.getPrescribedMedicines().trim()); // Fixed to match camelCase from Prescription.java
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error inserting data into prescriptions table:");
            e.printStackTrace();
            return false;
        }
    }
}