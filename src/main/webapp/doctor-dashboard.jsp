<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="com.healthcare.model.Appointment" %>
<%@ page import="com.healthcare.dao.AppointmentDAO" %>
<%@ page import="com.healthcare.dao.AppointmentDAOImpl" %>
<%@ page import="java.util.List" %>
<%
    // Session Validation Guard
    User currentUser = (User) session.getAttribute("currentUser");
    String userRole = (String) session.getAttribute("userRole");

    if (currentUser == null || !"DOCTOR".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch dynamic appointments using current active session tracking metrics
    Integer doctorId = (Integer) session.getAttribute("doctorId");
    List<Appointment> appointmentList = null;
    if (doctorId != null) {
        AppointmentDAO dao = new AppointmentDAOImpl();
        appointmentList = dao.getAppointmentsByDoctorId(doctorId);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Doctor Dashboard - Healthcare System</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px; }
        .dashboard-box { background: white; padding: 30px; border-radius: 8px; max-width: 950px; margin: 50px auto; box-shadow: 0 4px 15 rgba(0,0,0,0.1); }
        h1 { color: #2980b9; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .welcome-text { font-size: 18px; color: #34495e; }
        .logout-btn { display: inline-block; background-color: #e74c3c; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin-top: 20px; font-weight: bold; }
        .logout-btn:hover { background-color: #c0392b; }
        
        /* Table layout optimizations */
        table { width: 100%; border-collapse: collapse; margin-top: 20px; text-align: left; }
        th, td { padding: 12px; border-bottom: 1px solid #e0e0e0; font-size: 14px; }
        th { background-color: #f8f9fa; color: #2c3e50; }
        .badge { padding: 3px 8px; border-radius: 12px; font-weight: bold; font-size: 11px; }
        .badge-pending { background: #ffeaa7; color: #b7791f; }
        
        /* Action buttons and banner alerts */
        .action-link { color: #2ecc71; text-decoration: none; font-weight: bold; }
        .action-link:hover { text-decoration: underline; }
        .status-alert { padding: 12px; margin-top: 15px; border-radius: 4px; font-weight: bold; color: white; }
    </style>
</head>
<body>

<div class="dashboard-box">
    <h1>Medical Practitioner Workspace</h1>
    <p class="welcome-text">Welcome back, Dr. <strong><%= currentUser.getUsername() %></strong>!</p>
    <hr>
    
    <%
        String successMsg = request.getParameter("success");
        String errorMsg = request.getParameter("error");
        if (successMsg != null) {
    %>
        <div class="status-alert" style="background-color: #2ecc71;"><%= successMsg %></div>
    <% } if (errorMsg != null) { %>
        <div class="status-alert" style="background-color: #e74c3c;"><%= errorMsg %></div>
    <% } %>
    
    <h3>🗓️ Scheduled Patient Consultations</h3>
    <table>
        <thead>
            <tr>
                <th>Appointment ID</th>
                <th>Patient ID</th>
                <th>Date Requested</th>
                <th>Time Window Slot</th>
                <th>Symptoms Description</th>
                <th>Current Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
            if (appointmentList != null && !appointmentList.isEmpty()) {
                for (Appointment appt : appointmentList) {
        %>
            <tr>
                <td>#<%= appt.getAppointmentId() %></td>
                <td>Patient #<%= appt.getPatientId() %></td>
                <td><%= appt.getAppointmentDate() %></td>
                <td><%= appt.getTimeSlot() %></td>
                <td><%= appt.getSymptoms() %></td>
                <td><span class="badge badge-pending"><%= appt.getStatus() %></span></td>
                <td>
                    <a href="add-prescription.jsp?appointmentId=<%= appt.getAppointmentId() %>" class="action-link">✍️ Prescribe</a>
                </td>
            </tr>
        <% 
                }
            } else {
        %>
            <tr>
                <td colspan="7" style="color: #7f8c8d; font-style: italic; text-align: center; padding: 20px;">No pending schedules allocated to your ID profile window.</td>
            </tr>
        <% } %>
        </tbody>
    </table>

    <a href="login.jsp" class="logout-btn">Secure Logout</a>
</div>

</body>
</html>