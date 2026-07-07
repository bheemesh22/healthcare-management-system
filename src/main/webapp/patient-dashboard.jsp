<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="com.healthcare.model.PatientProfile" %>
<%
    // Session Validation Guard
    User currentUser = (User) session.getAttribute("currentUser");
    String userRole = (String) session.getAttribute("userRole");

    if (currentUser == null || !"PATIENT".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Retrieve profile data injected by the servlet
    PatientProfile profile = (PatientProfile) request.getAttribute("patientProfile");
    
    // If a user navigates here directly without going through the servlet, forward them to the servlet to load data
    if (profile == null && request.getAttribute("profileRedirectChecked") == null) {
        request.setAttribute("profileRedirectChecked", "true");
        request.getRequestDispatcher("patient/profile").forward(request, response);
        return;
    }

    // Helper fallbacks to prevent empty strings or null pointer exceptions in text fields
    String dob = (profile != null && profile.getDateOfBirth() != null) ? profile.getDateOfBirth().toString() : "";
    String blood = (profile != null && profile.getBloodGroup() != null) ? profile.getBloodGroup() : "";
    String phone = (profile != null && profile.getPhoneNumber() != null) ? profile.getPhoneNumber() : "";
    String address = (profile != null && profile.getAddress() != null) ? profile.getAddress() : "";
    String history = (profile != null && profile.getMedicalHistory() != null) ? profile.getMedicalHistory() : "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Patient Portal - Healthcare System</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px; }
        .container { max-width: 900px; margin: 30px auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.08); }
        .header-bar { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #2ecc71; padding-bottom: 15px; margin-bottom: 25px; }
        h1 { color: #27ae60; margin: 0; font-size: 28px; }
        .user-info { font-size: 14px; color: #7f8c8d; text-align: right; }
        .logout-btn { background-color: #e74c3c; color: white; padding: 8px 16px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 13px; }
        .logout-btn:hover { background-color: #c0392b; }
        
        .alert { padding: 12px; border-radius: 4px; margin-bottom: 20px; text-align: center; font-size: 14px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        .layout-grid { display: grid; grid-template-columns: 1fr 2fr; gap: 30px; }
        .sidebar-card { background: #f8f9fa; padding: 20px; border-radius: 6px; border-left: 4px solid #27ae60; height: fit-content; }
        .sidebar-card h3 { margin-top: 0; color: #2c3e50; }
        
        .form-group { margin-bottom: 18px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #34495e; font-size: 14px; }
        input[type="text"], input[type="date"], select, textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-size: 14px; font-family: inherit; }
        textarea { resize: vertical; height: 100px; }
        input:focus, select:focus, textarea:focus { border-color: #2ecc71; outline: none; }
        
        .btn-save { background-color: #2ecc71; color: white; border: none; padding: 12px 20px; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer; width: 100%; transition: background 0.2s; }
        .btn-save:hover { background-color: #27ae60; }
    </style>
</head>
<body>

<div class="container">
    <div class="header-bar">
        <div>
            <h1>Patient Personal Care Portal</h1>
        </div>
        <div class="user-info">
            Welcome, <strong><%= currentUser.getUsername() %></strong><br>
            Account Email: <%= currentUser.getEmail() %><br><br>
            <a href="login.jsp" class="logout-btn">Secure Logout</a>
        </div>
    </div>

    <%-- Success & Error Alerts --%>
    <% if (request.getAttribute("successMessage") != null) { %>
        <div class="alert alert-success"><%= request.getAttribute("successMessage") %></div>
    <% } %>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("errorMessage") %></div>
    <% } %>

    <div class="layout-grid">
        <div class="sidebar-card">
            <h3>Medical Summary</h3>
            <p><strong>Blood Group:</strong> <%= blood.isEmpty() ? "Not Provided" : blood %></p>
            <p><strong>Date of Birth:</strong> <%= dob.isEmpty() ? "Not Provided" : dob %></p>
            <p><strong>Contact:</strong> <%= phone.isEmpty() ? "Not Provided" : phone %></p>
            <hr style="border: 0; border-top: 1px solid #ddd; margin: 15px 0;">
            <p><strong>Active Diagnostic Files:</strong></p>
            <span style="font-size: 13px; color: #7f8c8d;">No digital files attached to your medical history record.</span>
        </div>

        <div>
            <h3 style="color: #2c3e50; margin-top: 0; border-bottom: 1px solid #eee; padding-bottom: 10px;">Update Health Profile Details</h3>
            <form action="patient/profile" method="POST">
                <div class="form-group">
                    <label for="dateOfBirth">Date of Birth</label>
                    <input type="date" id="dateOfBirth" name="dateOfBirth" value="<%= dob %>">
                </div>

                <div class="form-group">
                    <label for="bloodGroup">Blood Group</label>
                    <select id="bloodGroup" name="bloodGroup">
                        <option value="">-- Select Blood Group --</option>
                        <option value="A+" <%= "A+".equals(blood) ? "selected" : "" %>>A+</option>
                        <option value="A-" <%= "A-".equals(blood) ? "selected" : "" %>>A-</option>
                        <option value="B+" <%= "B+".equals(blood) ? "selected" : "" %>>B+</option>
                        <option value="B-" <%= "B-".equals(blood) ? "selected" : "" %>>B-</option>
                        <option value="AB+" <%= "AB+".equals(blood) ? "selected" : "" %>>AB+</option>
                        <option value="AB-" <%= "AB-".equals(blood) ? "selected" : "" %>>AB-</option>
                        <option value="O+" <%= "O+".equals(blood) ? "selected" : "" %>>O+</option>
                        <option value="O-" <%= "O-".equals(blood) ? "selected" : "" %>>O-</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="phoneNumber">Phone Number</label>
                    <input type="text" id="phoneNumber" name="phoneNumber" value="<%= phone %>" placeholder="e.g. +15551234567">
                </div>

                <div class="form-group">
                    <label for="address">Residential Address</label>
                    <textarea id="address" name="address" placeholder="Enter your full home address..."><%= address %></textarea>
                </div>

                <div class="form-group">
                    <label for="medicalHistory">Personal Medical History / Chronic Conditions</label>
                    <textarea id="medicalHistory" name="medicalHistory" placeholder="List any known allergies, previous surgeries, or ongoing treatments..."><%= history %></textarea>
                </div>

                <button type="submit" class="btn-save">Save Profile Changes</button>
            </form>
        </div>
    </div>
</div>

</body>
</html>