<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="com.healthcare.dao.AppointmentDAOImpl" %>
<%@ page import="com.healthcare.model.Prescription" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"PATIENT".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    AppointmentDAOImpl appointmentDAO = new AppointmentDAOImpl();
    List<Prescription> prescriptionList = appointmentDAO.getPrescriptionsByPatientId(currentUser.getUserId());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Rx Digital Prescriptions</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; padding: 40px; color: #2c3e50; }
        .container { max-width: 900px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .back-btn { background-color: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; font-weight: bold; }
        
        .prescription-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-bottom: 20px; border-left: 5px solid #2ecc71; }
        .doc-title { font-size: 18px; color: #2c3e50; font-weight: bold; margin-bottom: 10px; }
        .meta-text { font-size: 12px; color: #7f8c8d; margin-bottom: 15px; }
        .section-block { margin-bottom: 12px; }
        .section-label { font-size: 13px; font-weight: bold; color: #34495e; text-transform: uppercase; margin-bottom: 4px; }
        .section-content { font-size: 15px; background: #fcfcfc; padding: 10px; border: 1px solid #eee; border-radius: 4px; white-space: pre-line; }
        .no-records { text-align: center; background: white; padding: 50px; border-radius: 8px; color: #7f8c8d; font-style: italic; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>💊 Medical Prescriptions & Diagnostics</h1>
        <a href="patient-dashboard.jsp" class="back-btn">← Back to Dashboard</a>
    </div>

    <% if (prescriptionList == null || prescriptionList.isEmpty()) { %>
        <div class="no-records">No medical prescriptions have been issued to your patient profile history profile yet.</div>
    <% } else { 
        for (Prescription rx : prescriptionList) { %>
            <div class="prescription-card">
                <div class="doc-title">Dr. <%= rx.getDoctorName() %></div>
                <div class="meta-text">Issued on: <%= rx.getCreatedAt() %> | Ref ID: #RX-<%= rx.getPrescriptionId() %></div>
                
                <div class="section-block">
                    <div class="section-label">Diagnosis</div>
                    <div class="section-content" style="font-weight: 600; color: #c0392b;"><%= rx.getDiagnosis() %></div>
                </div>
                
                <div class="section-block">
                    <div class="section-label">Prescribed Medications</div>
                    <div class="section-content" style="background: #f4fff7; border-color: #d1f2db;"><%= rx.getPrescribedMedicines() %></div>
                </div>

                <% if(rx.getDoctorNotes() != null && !rx.getDoctorNotes().trim().isEmpty()) { %>
                    <div class="section-block">
                        <div class="section-label">Doctor Notes / Instructions</div>
                        <div class="section-content"><%= rx.getDoctorNotes() %></div>
                    </div>
                <% } %>
            </div>
    <% } 
    } %>
</div>
</body>
</html>