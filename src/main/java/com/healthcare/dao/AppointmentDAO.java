package com.healthcare.dao;

import java.util.List;
import com.healthcare.model.Appointment;

public interface AppointmentDAO {
    boolean bookAppointment(Appointment appointment);
    boolean updatePatientProfile(int userId, String phone, java.sql.Date dob, String gender, String bloodGroup);
    java.util.List<com.healthcare.model.Prescription> getPrescriptionsByPatientId(int userId);
    boolean insertPrescription(int appointmentId, String diagnosis, String medicines, String notes);
    List<Appointment> getAppointmentsByPatientId(int patientId);
    List<Appointment> getAppointmentsByDoctorId(int doctorId);
}