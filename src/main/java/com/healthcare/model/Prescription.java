package com.healthcare.model;

import java.sql.Timestamp;

public class Prescription {
    private int prescription_id;
    private int appointment_id;
    private String diagnosis;
    private String doctor_notes;
    private String prescribed_medicines;
    private Timestamp created_at;
    
    // Additional join attribute for UI display
    private String doctorName;

    // Getters and Setters
    public int getPrescriptionId() { return prescription_id; }
    public void setPrescriptionId(int prescription_id) { this.prescription_id = prescription_id; }

    public int getAppointmentId() { return appointment_id; }
    public void setAppointmentId(int appointment_id) { this.appointment_id = appointment_id; }

    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }

    public String getDoctorNotes() { return doctor_notes; }
    public void setDoctorNotes(String doctor_notes) { this.doctor_notes = doctor_notes; }

    public String getPrescribedMedicines() { return prescribed_medicines; }
    public void setPrescribedMedicines(String prescribed_medicines) { this.prescribed_medicines = prescribed_medicines; }

    public Timestamp getCreatedAt() { return created_at; }
    public void setCreatedAt(Timestamp created_at) { this.created_at = created_at; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }
}