package com.healthcare.controller;

import java.io.IOException;
import java.sql.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.healthcare.dao.PatientDAO;
import com.healthcare.dao.PatientDAOImpl;
import com.healthcare.model.PatientProfile;
import com.healthcare.model.User;

@WebServlet("/patient/profile")
public class PatientProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        this.patientDAO = new PatientDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Enforce session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        
        // 2. Load profile record from database
        PatientProfile profile = patientDAO.getProfileByUserId(currentUser.getId());
        
        // 3. Attach profile to request scope and route to dashboard view
        request.setAttribute("patientProfile", profile);
        request.getRequestDispatcher("../patient-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Enforce session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        // 2. Gather form data inputs
        String dobString = request.getParameter("dateOfBirth");
        String bloodGroup = request.getParameter("bloodGroup");
        String phoneNumber = request.getParameter("phoneNumber");
        String address = request.getParameter("address");
        String medicalHistory = request.getParameter("medicalHistory");

        // 3. Construct the Profile Domain Object
        PatientProfile profile = new PatientProfile();
        profile.setUserId(currentUser.getId());
        profile.setBloodGroup(bloodGroup);
        profile.setPhoneNumber(phoneNumber);
        profile.setAddress(address);
        profile.setMedicalHistory(medicalHistory);

        // Safely parse date value if provided
        if (dobString != null && !dobString.trim().isEmpty()) {
            try {
                profile.setDateOfBirth(Date.valueOf(dobString));
            } catch (IllegalArgumentException e) {
                // Keep default null date value if parsing fails
            }
        }

        // 4. Save updates to database
        boolean success = patientDAO.saveOrUpdateProfile(profile);

        if (success) {
            request.setAttribute("successMessage", "Your medical profile has been updated successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to update profile records. Please check inputs.");
        }

        // 5. Reload fresh state by passing back into doGet method execution chain
        doGet(request, response);
    }
}