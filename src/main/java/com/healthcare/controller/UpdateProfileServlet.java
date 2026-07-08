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

@WebServlet("/updatePatientProfile")
public class UpdateProfileServlet extends HttpServlet {
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
            // Extract attributes from form fields
            String phone = request.getParameter("phone");
            String dobStr = request.getParameter("dateOfBirth");
            String gender = request.getParameter("gender");
            String bloodGroup = request.getParameter("bloodGroup");

            int userId = currentUser.getUserId();
            Date dateOfBirth = Date.valueOf(dobStr); // Formats string text YYYY-MM-DD cleanly

            // Execute update context
            boolean success = appointmentDAO.updatePatientProfile(userId, phone, dateOfBirth, gender, bloodGroup);

            if (success) {
                response.sendRedirect("patient-dashboard.jsp?success=Profile updated successfully!");
            } else {
                response.sendRedirect("profile-settings.jsp?error=Failed to save changes to database.");
            }

        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            response.sendRedirect("profile-settings.jsp?error=Invalid parameters or date formats submitted.");
        }
    }
}