package com.healthcare.controller;

import java.io.IOException;
import java.sql.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.healthcare.dao.AppointmentDAO;
import com.healthcare.dao.AppointmentDAOImpl;
import com.healthcare.model.Appointment;

@WebServlet("/bookAppointment")
public class AppointmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppointmentDAO appointmentDAO = new AppointmentDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 1. Extract values from the form inputs
        try {
            // NOTE: In the next step, we ensure the patientId is loaded into the session 
            // when they log in or set up their profile.
            Integer patientId = (Integer) session.getAttribute("patientId");
            if (patientId == null) {
                response.sendRedirect("patient-dashboard.jsp?error=Profile incomplete. Please fill medical profile first.");
                return;
            }

            int doctorId = Integer.parseInt(request.getParameter("doctorId"));
            String dateStr = request.getParameter("appointmentDate");
            String timeSlot = request.getParameter("timeSlot");
            String symptoms = request.getParameter("symptoms");

            // 2. Populate the data model
            Appointment appointment = new Appointment();
            appointment.setPatientId(patientId);
            appointment.setDoctorId(doctorId);
            appointment.setAppointmentDate(Date.valueOf(dateStr)); // Formats YYYY-MM-DD
            appointment.setTimeSlot(timeSlot);
            appointment.setSymptoms(symptoms);

            // 3. Persist to database using our DAO contract logic
            boolean success = appointmentDAO.bookAppointment(appointment);

            if (success) {
                response.sendRedirect("patient-dashboard.jsp?success=Appointment booked successfully!");
            } else {
                response.sendRedirect("patient-dashboard.jsp?error=Database booking insertion failed.");
            }

        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            response.sendRedirect("patient-dashboard.jsp?error=Invalid form inputs or dates provided.");
        }
    }
}