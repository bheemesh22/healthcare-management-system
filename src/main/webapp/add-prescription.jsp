<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"DOCTOR".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String apptId = request.getParameter("appointmentId");
    if (apptId == null) {
        response.sendRedirect("doctor-dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Issue Digital Rx Prescription</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; padding: 40px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .container { background: white; padding: 35px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.06); width: 100%; max-width: 550px; border-top: 5px solid #2ecc71; }
        h2 { color: #2c3e50; margin-bottom: 20px; text-align: center; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 6px; color: #34495e; font-weight: bold; font-size: 14px; }
        .form-group input, .form-group textarea { width: 100%; padding: 12px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; outline: none; }
        textarea { resize: vertical; height: 100px; }
        .btn-submit { width: 100%; background: #2ecc71; color: white; border: none; padding: 14px; border-radius: 4px; font-size: 16px; font-weight: bold; cursor: pointer; }
        .btn-submit:hover { background: #27ae60; }
        .back-link { display: block; text-align: center; margin-top: 15px; color: #7f8c8d; text-decoration: none; font-size: 14px; }
    </style>
</head>
<body>
<div class="container">
    <h2>✍️ Issue Digital Prescription</h2>
    <p style="text-align: center; color: #7f8c8d; margin-bottom: 20px; font-size: 13px;">Assigning Medical Rx for Appointment #<%= apptId %></p>
    
    <form action="submitPrescription" method="POST">
        <input type="hidden" name="appointmentId" value="<%= apptId %>">
        
        <div class="form-group">
            <label>Clinical Diagnosis / Condition</label>
            <input type="text" name="diagnosis" placeholder="e.g., Acute Bronchitis, Seasonal Allergies" required>
        </div>
        
        <div class="form-group">
            <label>Prescribed Medicines (Name & Dosage Schedule)</label>
            <textarea name="medicines" placeholder="e.g., Amoxicillin 500mg - 3 times a day for 5 days&#10;Paracetamol 650mg - As needed for fever" required></textarea>
        </div>
        
        <div class="form-group">
            <label>Special Instructions / Doctor Notes (Optional)</label>
            <textarea name="notes" placeholder="e.g., Drink plenty of fluids, rest well, review if fever doesn't drop in 3 days..."></textarea>
        </div>
        
        <button type="submit" class="btn-submit">Submit Prescription</button>
        <a href="doctor-dashboard.jsp" class="back-link">← Cancel and Go Back</a>
    </form>
</div>
</body>
</html>