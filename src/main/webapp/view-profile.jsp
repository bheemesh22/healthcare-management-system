<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="com.healthcare.model.PatientProfile" %>
<%@ page import="com.healthcare.dao.PatientDAO" %>
<%@ page import="com.healthcare.dao.PatientDAOImpl" %>
<%
    // Session Security Guard
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"PATIENT".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Instantiating your DAO Implementation
    PatientDAO patientDAO = new PatientDAOImpl();
    PatientProfile profile = patientDAO.getProfileByUserId(currentUser.getUserId());

    // Fallback bindings if profile variables are null/empty
    String dob = (profile != null && profile.getDateOfBirth() != null) ? profile.getDateOfBirth().toString() : "Not provided";
    String bloodGroup = (profile != null && profile.getBloodGroup() != null) ? profile.getBloodGroup() : "Not checked";
    String phone = (profile != null && profile.getPhoneNumber() != null) ? profile.getPhoneNumber() : "Not provided";
    String address = (profile != null && profile.getAddress() != null) ? profile.getAddress() : "Not provided";
    String history = (profile != null && profile.getMedicalHistory() != null) ? profile.getMedicalHistory() : "No recorded chronic illness history.";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Medical Profile</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; display: flex; min-height: 100vh; }
        
        .sidebar { width: 260px; background-color: #2c3e50; color: white; padding: 30px 20px; }
        .sidebar h2 { margin-bottom: 30px; font-size: 22px; text-align: center; border-bottom: 2px solid #34495e; padding-bottom: 10px; }
        .sidebar a { display: block; color: #bdc3c7; padding: 12px 15px; text-decoration: none; margin-bottom: 8px; border-radius: 4px; transition: 0.3s; }
        .sidebar a:hover, .sidebar a.active { background-color: #3498db; color: white; }
        
        .main-content { flex: 1; padding: 40px; overflow-y: auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        
        .profile-container { background: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); padding: 35px; border-top: 5px solid #3498db; max-width: 800px; }
        .profile-card-header { display: flex; align-items: center; gap: 20px; margin-bottom: 30px; }
        .avatar-circle { width: 70px; height: 70px; background: #e1e8ed; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 32px; color: #3498db; }
        .profile-title-details h2 { color: #2c3e50; }
        .profile-title-details p { color: #7f8c8d; font-size: 14px; }
        
        .info-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 30px; }
        .info-block { background: #f8f9fa; padding: 15px; border-radius: 6px; border-left: 3px solid #bdc3c7; }
        .info-block.critical { border-left-color: #e74c3c; }
        .info-block label { display: block; font-size: 12px; font-weight: bold; text-transform: uppercase; color: #7f8c8d; margin-bottom: 4px; }
        .info-block p { font-size: 15px; color: #2c3e50; font-weight: 500; }
        
        .full-width-block { grid-column: span 2; }
        .btn-edit { display: inline-block; background-color: #3498db; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; transition: 0.2s; }
        .btn-edit:hover { background-color: #2980b9; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h2>HealthSync AI</h2>
        <a href="patient-dashboard.jsp">Dashboard Home</a>
        <a href="my-appointments.jsp">My Appointments</a>
        <a href="medical-records.jsp">Medical Records</a>
        <a href="view-prescriptions.jsp">Prescriptions</a>
        <a href="view-profile.jsp" class="active">My Medical Profile</a>
        <a href="profile-settings.jsp">Settings Profile</a>
    </div>

    <div class="main-content">
        <div class="header">
            <h1>🛡️ Patient Health Passport</h1>
            <a href="patient-dashboard.jsp" class="btn-edit" style="background-color: #7f8c8d;">Dashboard Home</a>
        </div>

        <div class="profile-container">
            <div class="profile-card-header">
                <div class="avatar-circle">👤</div>
                <div class="profile-title-details">
                    <h2><%= currentUser.getFullName() %></h2>
                    <p>Patient ID Reference: #<%= currentUser.getUserId() %> | Account Status: <span style="color:#2ecc71; font-weight:bold;">Verified</span></p>
                </div>
            </div>
            
            <div class="info-grid">
                <div class="info-block"><label>Account Email Identity</label><p><%= currentUser.getEmail() %></p></div>
                <div class="info-block"><label>Primary Phone Number</label><p><%= phone %></p></div>
                <div class="info-block"><label>Date of Birth</label><p><%= dob %></p></div>
                <div class="info-block critical"><label>🩸 Blood Group Signature</label><p><%= bloodGroup %></p></div>
                <div class="info-block full-width-block"><label>🏠 Residential Address Location</label><p><%= address %></p></div>
                <div class="info-block full-width-block"><label>📜 Historical Medical Complications Record</label><p><%= history %></p></div>
            </div>
            
            <a href="profile-settings.jsp" class="btn-edit">✏️ Edit Settings Profile</a>
        </div>
    </div>

</body>
</html>