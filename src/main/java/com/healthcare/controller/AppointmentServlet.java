package com.healthcare.controller;

import java.io.IOException;
import java.sql.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.healthcare.model.User;
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

        User currentUser = (User) session.getAttribute("currentUser");

        try {
            // FIX: Use the baseline system user_id. Our updated DAO will use a SQL subquery 
            // to fetch or provision the correct row inside the patients table dynamically!
            int userId = currentUser.getUserId(); 

            int doctorId = Integer.parseInt(request.getParameter("doctorId"));
            String dateStr = request.getParameter("appointmentDate");
            String timeSlot = request.getParameter("timeSlot");
            String symptoms = request.getParameter("symptoms");

            // Populate the data model
            Appointment appointment = new Appointment();
            appointment.setPatientId(userId); // Storing user_id temporarily inside the patientId attribute field
            appointment.setDoctorId(doctorId);
            appointment.setAppointmentDate(Date.valueOf(dateStr)); 
            appointment.setTimeSlot(timeSlot);
            appointment.setSymptoms(symptoms);

            // Persist using your custom DAO subquery implementation block
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