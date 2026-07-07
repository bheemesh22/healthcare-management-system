package com.healthcare.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.healthcare.model.Appointment;
import com.healthcare.util.DBConnection;

public class AppointmentDAOImpl implements AppointmentDAO {

    @Override
    public boolean bookAppointment(Appointment appt) {
        // Matches your columns exactly: patient_id, doctor_id, appointment_date, time_slot, symptoms
        String sql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, time_slot, symptoms, status) VALUES (?, ?, ?, ?, ?, 'PENDING')";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, appt.getPatientId());
            ps.setInt(2, appt.getDoctorId());
            ps.setDate(3, appt.getAppointmentDate());
            ps.setString(4, appt.getTimeSlot().trim());
            ps.setString(5, appt.getSymptoms() != null ? appt.getSymptoms().trim() : "");
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error inserting into appointments table:");
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Appointment> getAppointmentsByPatientId(int patientId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT * FROM appointments WHERE patient_id = ? ORDER BY appointment_date ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment appt = new Appointment();
                    appt.setAppointmentId(rs.getInt("appointment_id"));
                    appt.setPatientId(rs.getInt("patient_id"));
                    appt.setDoctorId(rs.getInt("doctor_id"));
                    appt.setAppointmentDate(rs.getDate("appointment_date"));
                    appt.setTimeSlot(rs.getString("time_slot"));
                    appt.setSymptoms(rs.getString("symptoms"));
                    appt.setStatus(rs.getString("status"));
                    appt.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(appt);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Appointment> getAppointmentsByDoctorId(int doctorId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT * FROM appointments WHERE doctor_id = ? ORDER BY appointment_date ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment appt = new Appointment();
                    appt.setAppointmentId(rs.getInt("appointment_id"));
                    appt.setPatientId(rs.getInt("patient_id"));
                    appt.setDoctorId(rs.getInt("doctor_id"));
                    appt.setAppointmentDate(rs.getDate("appointment_date"));
                    appt.setTimeSlot(rs.getString("time_slot"));
                    appt.setSymptoms(rs.getString("symptoms"));
                    appt.setStatus(rs.getString("status"));
                    appt.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(appt);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}