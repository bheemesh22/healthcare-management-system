<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Patient Profile Settings</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; padding: 40px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .container { background: white; padding: 35px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); width: 100%; max-width: 500px; border-top: 5px solid #2ecc71; }
        h2 { margin-bottom: 20px; color: #2c3e50; text-align: center; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 6px; color: #34495e; font-weight: bold; font-size: 14px; }
        .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; }
        .btn-save { width: 100%; background: #2ecc71; color: white; border: none; padding: 12px; border-radius: 4px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 10px; }
        .btn-save:hover { background: #27ae60; }
        .back-link { display: block; text-align: center; margin-top: 15px; color: #7f8c8d; text-decoration: none; font-size: 14px; }
    </style>
</head>
<body>
<div class="container">
    <h2>Update Medical Demographics</h2>
    <form action="updatePatientProfile" method="POST">
        <div class="form-group">
            <label>Phone Number</label>
            <input type="text" name="phone" placeholder="e.g., +1 234 567 8901" required>
        </div>
        <div class="form-group">
            <label>Date of Birth</label>
            <input type="date" name="dateOfBirth" required>
        </div>
        <div class="form-group">
            <label>Gender Identity</label>
            <select name="gender" required>
                <option value="MALE">Male</option>
                <option value="FEMALE">Female</option>
                <option value="OTHER">Other</option>
            </select>
        </div>
        <div class="form-group">
            <label>Blood Group</label>
            <input type="text" name="bloodGroup" placeholder="e.g., O+, A-" maxlength="5" required>
        </div>
        <button type="submit" class="btn-save">Save Demographics</button>
        <a href="patient-dashboard.jsp" class="back-link">← Cancel and Back</a>
    </form>
</div>
</body>
</html>