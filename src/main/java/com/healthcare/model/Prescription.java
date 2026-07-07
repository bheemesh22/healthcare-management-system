package com.healthcare.model;

import java.sql.Timestamp;

public class Prescription {
    private int prescriptionId;
    private int appointmentId;
    private String diagnosis;
    private String doctorNotes;
    private String prescribedMedicines;
    private Timestamp createdAt;

    // Default Constructor
    public Prescription() {}

    // Getters and Setters
    public int getPrescriptionId() { return prescriptionId; }
    public void setPrescriptionId(int prescriptionId) { this.prescriptionId = prescriptionId; }

    public int getAppointmentId() { return appointmentId; }
    public void setAppointmentId(int appointmentId) { this.appointmentId = appointmentId; }

    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }

    public String getDoctorNotes() { return doctorNotes; }
    public void setDoctorNotes(String doctorNotes) { this.doctorNotes = doctorNotes; }

    public String getPrescribedMedicines() { return prescribedMedicines; }
    public void setPrescribedMedicines(String prescribedMedicines) { this.prescribedMedicines = prescribedMedicines; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}