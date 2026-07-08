package com.healthcare.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.healthcare.dao.AppointmentDAO;
import com.healthcare.dao.AppointmentDAOImpl;

@WebServlet("/submitPrescription")
public class AddPrescriptionServlet extends HttpServlet {
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

        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String diagnosis = request.getParameter("diagnosis");
            String medicines = request.getParameter("medicines");
            String notes = request.getParameter("notes");

            boolean success = appointmentDAO.insertPrescription(appointmentId, diagnosis, medicines, notes);

            if (success) {
                response.sendRedirect("doctor-dashboard.jsp?success=Prescription added successfully!");
            } else {
                response.sendRedirect("doctor-dashboard.jsp?error=Failed to insert prescription entry.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("doctor-dashboard.jsp?error=Invalid prescription data submitted.");
        }
    }
}