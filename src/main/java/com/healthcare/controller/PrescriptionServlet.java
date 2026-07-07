package com.healthcare.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.healthcare.dao.PrescriptionDAOImpl;
import com.healthcare.model.Prescription;
import com.healthcare.model.User;

@WebServlet("/addPrescription")
public class PrescriptionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final PrescriptionDAOImpl prescriptionDAO = new PrescriptionDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (!"DOCTOR".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp?error=Unauthorized access layer.");
            return;
        }

        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String diagnosis = request.getParameter("diagnosis");
            String doctorNotes = request.getParameter("doctorNotes");
            String prescribedMedicines = request.getParameter("prescribedMedicines");

            // Build out the target model context
            Prescription prescription = new Prescription();
            prescription.setAppointmentId(appointmentId);
            prescription.setDiagnosis(diagnosis);
            prescription.setDoctorNotes(doctorNotes);
            prescription.setPrescribedMedicines(prescribedMedicines);

            boolean success = prescriptionDAO.addPrescription(prescription);

            if (success) {
                response.sendRedirect("doctor-dashboard.jsp?success=Prescription submitted successfully!");
            } else {
                response.sendRedirect("doctor-dashboard.jsp?error=Failed to insert prescription entry.");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("doctor-dashboard.jsp?error=Invalid appointment identity format.");
        }
    }
}