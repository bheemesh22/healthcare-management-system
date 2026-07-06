<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%
    // Session Validation Guard
    User currentUser = (User) session.getAttribute("currentUser");
    String userRole = (String) session.getAttribute("userRole");

    if (currentUser == null || !"PATIENT".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Patient Dashboard - Healthcare System</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px; }
        .dashboard-box { background: white; padding: 30px; border-radius: 8px; max-width: 800px; margin: 50px auto; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        h1 { color: #27ae60; border-bottom: 2px solid #2ecc71; padding-bottom: 10px; }
        .welcome-text { font-size: 18px; color: #34495e; }
        .logout-btn { display: inline-block; background-color: #e74c3c; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin-top: 20px; font-weight: bold; }
        .logout-btn:hover { background-color: #c0392b; }
    </style>
</head>
<body>

<div class="dashboard-box">
    <h1>Patient Personal Care Portal</h1>
    <p class="welcome-text">Welcome back, <strong><%= currentUser.getUsername() %></strong>!</p>
    <hr>
    <h3>My Medical Dashboard</h3>
    <ul>
        <li>Book New Consultation Appointments with Registered Doctors</li>
        <li>Download Active Medical Prescriptions</li>
        <li>View Lab Results & Vaccination Records</li>
    </ul>
    <a href="login.jsp" class="logout-btn">Secure Logout</a>
</div>

</body>
</html>