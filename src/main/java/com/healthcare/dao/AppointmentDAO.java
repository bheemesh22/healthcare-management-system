package com.healthcare.dao;

import java.util.List;
import com.healthcare.model.Appointment;

public interface AppointmentDAO {
    boolean bookAppointment(Appointment appointment);
    List<Appointment> getAppointmentsByPatientId(int patientId);
    List<Appointment> getAppointmentsByDoctorId(int doctorId);
}