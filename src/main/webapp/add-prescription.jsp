<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%
    // Ensure the user is authenticated and is a verified DOCTOR before rendering the form
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"DOCTOR".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Capture the specific appointment target passing through the routing parameter context
    String appointmentIdStr = request.getParameter("appointmentId");
    if (appointmentIdStr == null || appointmentIdStr.trim().isEmpty()) {
        response.sendRedirect("doctor-dashboard.jsp?error=No active appointment reference selected.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Issue Medical Prescription</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; padding: 40px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .form-container { background: white; padding: 35px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.08); width: 100%; max-width: 600px; border-top: 5px solid #2ecc71; }
        h2 { color: #2c3e50; margin-bottom: 25px; text-align: center; }
        .appointment-info { background-color: #f8f9fa; padding: 12px; border-radius: 4px; margin-bottom: 20px; color: #7f8c8d; font-size: 14px; border-left: 3px solid #bdc3c7; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #34495e; font-weight: 600; font-size: 14px; }
        .form-group input, .form-group textarea { width: 100%; padding: 12px; border: 1px solid #ccc; border-radius: 4px; font-size: 15px; outline: none; transition: 0.2s; }
        .form-group input:focus, .form-group textarea:focus { border-color: #2ecc71; }
        textarea { resize: vertical; height: 100px; }
        .btn-submit { width: 100%; background-color: #2ecc71; color: white; border: none; padding: 14px; border-radius: 4px; font-size: 16px; font-weight: bold; cursor: pointer; transition: 0.3s; margin-top: 10px; }
        .btn-submit:hover { background-color: #27ae60; }
        .back-link { display: block; text-align: center; margin-top: 20px; color: #7f8c8d; text-decoration: none; font-size: 14px; }
        .back-link:hover { color: #2ecc71; }
    </style>
</head>
<body>

<div class="form-container">
    <h2>Issue Treatment Prescription</h2>
    
    <div class="appointment-info">
        <strong>Selected Context:</strong> Documenting records for Appointment Reference <strong>#<%= appointmentIdStr %></strong>
    </div>
    
    <form action="addPrescription" method="POST">
        
        <input type="hidden" name="appointmentId" value="<%= appointmentIdStr %>">
        
        <div class="form-group">
            <label for="diagnosis">Clinical Diagnosis / Assessment</label>
            <input type="text" name="diagnosis" id="diagnosis" placeholder="e.g., Acute Respiratory Infection, Hypertension Stage 1" required>
        </div>

        <div class="form-group">
            <label for="prescribedMedicines">Prescribed Medications & Dosages</label>
            <textarea name="prescribedMedicines" id="prescribedMedicines" placeholder="e.g., Amoxicillin 500mg - 3 times daily for 7 days" required></textarea>
        </div>

        <div class="form-group">
            <label for="doctorNotes">Additional Medical Advice / General Notes</label>
            <textarea name="doctorNotes" id="doctorNotes" placeholder="e.g., Patient advised complete bed rest for 3 days and increased fluid intake. Review if symptoms worsen."></textarea>
        </div>

        <button type="submit" class="btn-submit">Authorize and Issue Prescription</button>
        
        <a href="doctor-dashboard.jsp" class="back-link">← Cancel and Return to Workspace</a>
    </form>
</div>

</body>
</html>