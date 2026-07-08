<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="com.healthcare.dao.DoctorDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    // Session Validation Guard
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"DOCTOR".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp?error=Session expired or authorization restricted.");
        return;
    }

    DoctorDAO dao = new DoctorDAO();
    Map<String, Object> doctorProfile = dao.getDoctorProfileByUserId(currentUser.getUserId());
    
    int doctorId = (doctorProfile.containsKey("doctorId")) ? (Integer) doctorProfile.get("doctorId") : 0;
    String spec = (String) doctorProfile.get("specialization");
    Double fee = (Double) doctorProfile.get("consultationFee");
    String hours = (String) doctorProfile.get("availabilityHours");
    
    if (spec == null || spec.trim().isEmpty()) spec = "Not Assigned by Admin yet";
    if (fee == null) fee = 0.0;
    if (hours == null || hours.trim().isEmpty()) hours = "Not Set";

    List<Map<String, Object>> appointments = dao.getDoctorAppointments(doctorId);
    
    int totalBookings = appointments.size();
    int pendingCount = 0;
    for (Map<String, Object> app : appointments) {
        if ("PENDING".equalsIgnoreCase((String) app.get("status"))) pendingCount++;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Doctor Portal - Clinical Workspace</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; display: flex; min-height: 100vh; }
        .sidebar { width: 260px; background-color: #2c3e50; color: white; padding: 30px 20px; }
        .sidebar h2 { margin-bottom: 30px; font-size: 20px; text-align: center; border-bottom: 2px solid #34495e; padding-bottom: 10px; color: #9b59b6; }
        .sidebar button { display: block; width: 100%; background: none; border: none; text-align: left; color: #bdc3c7; padding: 12px 15px; margin-bottom: 8px; border-radius: 4px; font-weight: 500; font-size: 14px; cursor: pointer; }
        .sidebar button.active, .sidebar button:hover { background-color: #9b59b6; color: white; }
        .main-content { flex: 1; padding: 40px; overflow-y: auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .logout-btn { background-color: #e74c3c; color: white; padding: 10px 18px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; }
        
        .metrics-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 35px; }
        .metric-card { background: white; padding: 20px; border-radius: 6px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); border-left: 4px solid #9b59b6; }
        .metric-card.pending { border-left-color: #f39c12; }
        .metric-card h3 { color: #7f8c8d; font-size: 13px; text-transform: uppercase; margin-bottom: 5px; }
        .metric-card p { font-size: 28px; font-weight: bold; color: #2c3e50; }
        
        .status-alert { padding: 12px; margin-bottom: 25px; border-radius: 4px; font-weight: bold; color: white; font-size: 14px; text-align: center; }
        .data-panel { background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.04); padding: 25px; display: none; margin-bottom: 30px; }
        .data-panel.active-panel { display: block; }
        .panel-title { font-size: 18px; color: #2c3e50; margin-bottom: 20px; font-weight: 600; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: #34495e; font-weight: 600; margin-bottom: 8px; font-size: 14px; }
        .form-control { width: 100%; max-width: 400px; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; }
        .form-control:disabled { background-color: #eaeded; color: #7f8c8d; }
        .btn-submit { background-color: #9b59b6; color: white; border: none; padding: 10px 20px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px; }
        .btn-submit:hover { background-color: #8e44ad; }

        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 14px 12px; text-align: left; border-bottom: 1px solid #eef2f5; font-size: 14px; }
        th { background-color: #f8f9fa; color: #34495e; font-weight: 600; }
        
        .badge { padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; color: white; }
        .badge-PENDING { background-color: #f39c12; }
        .badge-CONFIRMED { background-color: #2ecc71; }
        .badge-CANCELLED { background-color: #e74c3c; }

        .btn-action { border: none; padding: 6px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; cursor: pointer; color: white; text-decoration: none; margin-right: 5px; }
        .btn-approve { background-color: #2ecc71; }
        .btn-cancel { background-color: #e74c3c; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h2>Doctor Portal</h2>
        <button class="nav-tab active" onclick="switchTab('appointments', this)">Schedules & Visitations</button>
        <button class="nav-tab" onclick="switchTab('profile', this)">Workspace Settings</button>
    </div>

    <div class="main-content">
        <div class="header">
            <h1>Welcome, Dr. <%= currentUser.getFullName() %></h1>
            <a href="logout" class="logout-btn">Secure Logout</a>
        </div>

        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) {
        %>
            <div class="status-alert" style="background-color: #2ecc71;"><%= successMsg %></div>
        <% } if (errorMsg != null) { %>
            <div class="status-alert" style="background-color: #e74c3c;"><%= errorMsg %></div>
        <% } %>

        <div id="appointments" class="data-panel active-panel">
            <div class="metrics-grid">
                <div class="metric-card"><h3>Total Case Bookings</h3><p><%= totalBookings %></p></div>
                <div class="metric-card pending"><h3>Actionable Requests Pending</h3><p><%= pendingCount %></p></div>
            </div>
            
            <div class="panel-title">📅 Live Medical Appointment Reservation Registry</div>
            <table>
                <thead>
                    <tr>
                        <th>Appointment ID</th>
                        <th>Patient Name Identity Profile</th>
                        <th>Target Reservation Date</th>
                        <th>Scheduled Time Slot</th>
                        <!-- FIXED UI: Patient Symptoms Column Header Incorporated -->
                        <th style="width: 28%;">Patient-Reported Symptoms</th>
                        <th>Status Badge</th>
                        <th>Management Controls</th>
                    </tr>
                </thead>
                <tbody>
                <% if (appointments.isEmpty()) { %>
                    <tr><td colspan="7" style="text-align:center; color:#95a5a6;">No appointment records currently mapped to your clinical index.</td></tr>
                <% } else {
                    for (Map<String, Object> app : appointments) {
                        int appId = (Integer) app.get("appointmentId");
                        String status = (String) app.get("status");
                        String patientSymptoms = (String) app.get("symptoms");
                %>
                    <tr>
                        <td><strong>#<%= appId %></strong></td>
                        <td><%= app.get("patientName") %></td>
                        <td><%= app.get("date") %></td>
                        <td><%= app.get("time") %></td>
                        
                        <!-- FIXED UI: Beautiful context element mapping raw symptoms details directly inside table row layout -->
                        <td>
                            <div style="background-color: #fff9db; color: #856404; padding: 6px 12px; border-radius: 4px; font-size: 12px; border-left: 3px solid #f5c06b; line-height: 1.4; max-width: 320px; word-wrap: break-word;">
                                <strong>Context:</strong> <%= patientSymptoms %>
                            </div>
                        </td>
                        
                        <td><span class="badge badge-<%= status %>"><%= status %></span></td>
                        <td>
                            <% if ("PENDING".equalsIgnoreCase(status)) { %>
                                <form action="doctor-action" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId" value="<%= appId %>">
                                    <input type="hidden" name="status" value="CONFIRMED">
                                    <button type="submit" class="btn-action btn-approve">Accept</button>
                                </form>
                                <form action="doctor-action" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId" value="<%= appId %>">
                                    <input type="hidden" name="status" value="CANCELLED">
                                    <button type="submit" class="btn-action btn-cancel">Cancel</button>
                                </form>
                            <% } else if ("CONFIRMED".equalsIgnoreCase(status)) { %>
                                <a href="add-prescription.jsp?appointmentId=<%= appId %>" class="btn-action" style="background-color: #3498db; text-decoration: none; display: inline-block; text-align: center;">+ Add Rx</a>
                            <% } else { %>
                                <span style="color:#95a5a6; font-size:13px;">No pending actions</span>
                            <% } %>
                        </td>
                    </tr>
                <% } } %>
                </tbody>
            </table>
        </div>

        <div id="profile" class="data-panel">
            <div class="panel-title">🩺 Manage Professional Healthcare Directory Details</div>
            <form action="doctor-action" method="POST">
                <input type="hidden" name="action" value="updateProfile">
                
                <div class="form-group">
                    <label>Medical Core Specialization Matrix (Assigned by Administrator)</label>
                    <input type="text" class="form-control" value="<%= spec %>" disabled>
                </div>
                
                <div class="form-group">
                    <label>Consultation Fee Charge ($ / INR)</label>
                    <input type="number" step="50" name="consultationFee" class="form-control" value="<%= fee %>" required>
                </div>
                
                <div class="form-group">
                    <label>Daily Availability Hours Window Signature</label>
                    <input type="text" name="availabilityHours" class="form-control" placeholder="e.g., 09:00 AM - 04:00 PM" value="<%= "Not Set".equals(hours) ? "" : hours %>" required>
                </div>
                
                <button type="submit" class="btn-submit">Synchronize Profile Settings</button>
            </form>
        </div>
    </div>

    <script>
        function switchTab(panelId, element) {
            document.querySelectorAll('.data-panel').forEach(panel => panel.classList.remove('active-panel'));
            document.querySelectorAll('.nav-tab').forEach(tab => tab.classList.remove('active'));
            document.getElementById(panelId).classList.add('active-panel');
            element.classList.add('active');
        }
    </script>
</body>
</html>