package com.healthcare.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.healthcare.dao.DoctorDAO;
import com.healthcare.model.User;

@WebServlet("/doctor-action")
public class DoctorActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DoctorDAO doctorDAO = new DoctorDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Secure role verification boundary check
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || !"DOCTOR".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp?error=Unauthorized medical dashboard routing access.");
            return;
        }

        String action = request.getParameter("action");
        
        try {
            if ("updateProfile".equals(action)) {
                double fee = Double.parseDouble(request.getParameter("consultationFee"));
                String hours = request.getParameter("availabilityHours");
                
                if (hours == null || hours.trim().isEmpty()) {
                    response.sendRedirect("doctor-dashboard.jsp?error=Availability hours cannot be empty.");
                    return;
                }
                
                if (doctorDAO.updateDoctorProfile(currentUser.getUserId(), fee, hours)) {
                    response.sendRedirect("doctor-dashboard.jsp?success=Clinical workspace profile settings synchronized.");
                } else {
                    response.sendRedirect("doctor-dashboard.jsp?error=Failed to write updated clinical variables.");
                }
                
            } else if ("updateStatus".equals(action)) {
                int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
                String status = request.getParameter("status"); // Expected: "CONFIRMED" or "CANCELLED"
                
                if (doctorDAO.updateAppointmentStatus(appointmentId, status)) {
                    response.sendRedirect("doctor-dashboard.jsp?success=Appointment status set to " + status + " successfully.");
                } else {
                    response.sendRedirect("doctor-dashboard.jsp?error=Failed to alter appointment scheduling status.");
                }
            } else {
                response.sendRedirect("doctor-dashboard.jsp?error=Invalid operating signature.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("doctor-dashboard.jsp?error=An internal scheduling runtime breakdown error occurred.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("doctor-dashboard.jsp");
    }
}