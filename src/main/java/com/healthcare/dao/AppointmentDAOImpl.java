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
        ensurePatientProfileExists(appt.getPatientId());

        String insertSql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, time_slot, symptoms, status) " +
                           "VALUES ((SELECT patient_id FROM patients WHERE user_id = ?), ?, ?, ?, ?, 'PENDING')";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql)) {
            
            ps.setInt(1, appt.getPatientId()); 
            ps.setInt(2, appt.getDoctorId());
            ps.setDate(3, appt.getAppointmentDate());
            ps.setString(4, appt.getTimeSlot().trim());
            ps.setString(5, appt.getSymptoms() != null ? appt.getSymptoms().trim() : "");
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Database Error executing appointment insertion workflow:");
            e.printStackTrace();
            return false;
        }
    }

    private void ensurePatientProfileExists(int userId) {
        String checkSql = "SELECT 1 FROM patients WHERE user_id = ?";
        String insertSql = "INSERT INTO patients (user_id, phone, date_of_birth, gender, blood_group) VALUES (?, 'Not Set', '2000-01-01', 'OTHER', 'N/A')";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, userId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) return;
                }
            }
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setInt(1, userId);
                insertPs.executeUpdate();
            }
        } catch (SQLException e) {
            System.err.println("❌ Error ensuring patient database row initialization profile: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public List<Appointment> getAppointmentsByPatientId(int userId) {
        List<Appointment> list = new ArrayList<>();
        // FIX: Ensuring we select using p.user_id to perfectly match the logged in session user!
        String sql = "SELECT a.* FROM appointments a " +
                     "JOIN patients p ON a.patient_id = p.patient_id " +
                     "WHERE p.user_id = ? " +
                     "ORDER BY a.appointment_date DESC, a.appointment_id DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId); // Passes the logged-in session user_id cleanly
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
            System.err.println("❌ Error loading appointments for history tab view:");
            e.printStackTrace();
        }
        return list;
    }
    
    @Override
    public boolean updatePatientProfile(int userId, String phone, java.sql.Date dob, String gender, String bloodGroup) {
        String sql = "UPDATE patients SET phone = ?, date_of_birth = ?, gender = ?, blood_group = ? WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, phone.trim());
            ps.setDate(2, dob);
            ps.setString(3, gender);
            ps.setString(4, bloodGroup.trim());
            ps.setInt(5, userId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error updating patient profile variables:");
            e.printStackTrace();
            return false;
        }
    }
    
    public List<com.healthcare.model.Prescription> getPrescriptionsByPatientId(int userId) {
        List<com.healthcare.model.Prescription> list = new ArrayList<>();
        String sql = "SELECT pr.*, u.full_name AS doctor_name " +
                     "FROM prescriptions pr " +
                     "JOIN appointments a ON pr.appointment_id = a.appointment_id " +
                     "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                     "JOIN users u ON d.user_id = u.user_id " +
                     "JOIN patients p ON a.patient_id = p.patient_id " +
                     "WHERE p.user_id = ? " +
                     "ORDER BY pr.created_at DESC";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.healthcare.model.Prescription pr = new com.healthcare.model.Prescription();
                    pr.setPrescriptionId(rs.getInt("prescription_id"));
                    pr.setAppointmentId(rs.getInt("appointment_id"));
                    pr.setDiagnosis(rs.getString("diagnosis"));
                    pr.setDoctorNotes(rs.getString("doctor_notes"));
                    pr.setPrescribedMedicines(rs.getString("prescribed_medicines"));
                    pr.setCreatedAt(rs.getTimestamp("created_at"));
                    pr.setDoctorName(rs.getString("doctor_name"));
                    list.add(pr);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error fetching active prescription items:");
            e.printStackTrace();
        }
        return list;
    }
    
    @Override
    public boolean insertPrescription(int appointmentId, String diagnosis, String medicines, String notes) {
        String sql = "INSERT INTO prescriptions (appointment_id, diagnosis, prescribed_medicines, doctor_notes) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, appointmentId);
            ps.setString(2, diagnosis.trim());
            ps.setString(3, medicines.trim());
            ps.setString(4, notes != null ? notes.trim() : "");
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error executing prescription table insertion:");
            e.printStackTrace();
            return false;
        }
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