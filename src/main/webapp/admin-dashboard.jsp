<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="com.healthcare.dao.AdminDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"ADMIN".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp?error=Session expired or authorization restricted.");
        return;
    }

    AdminDAO dao = new AdminDAO();
    List<Map<String, Object>> systemUsers = dao.getAllUsersWithDetails();
    Map<String, String> configs = dao.getSystemConfigurations();
    List<Map<String, String>> auditLogs = dao.getAuditTrackingLogs();
    
    int totalUsers = systemUsers.size();
    int activeDoctors = 0;
    int totalPatients = 0;
    int totalAdmins = 0;
    
    for (Map<String, Object> u : systemUsers) {
        String role = (String) u.get("role");
        if ("DOCTOR".equals(role)) activeDoctors++;
        else if ("PATIENT".equals(role)) totalPatients++;
        else if ("ADMIN".equals(role)) totalAdmins++;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>System Administration Command Center</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; display: flex; min-height: 100vh; }
        .sidebar { width: 260px; background-color: #2c3e50; color: white; padding: 30px 20px; }
        .sidebar h2 { margin-bottom: 30px; font-size: 20px; text-align: center; border-bottom: 2px solid #34495e; padding-bottom: 10px; color: #3498db; }
        .sidebar button { display: block; width: 100%; background: none; border: none; text-align: left; color: #bdc3c7; padding: 12px 15px; margin-bottom: 8px; border-radius: 4px; font-weight: 500; font-size: 14px; cursor: pointer; }
        .sidebar button.active, .sidebar button:hover { background-color: #3498db; color: white; }
        .main-content { flex: 1; padding: 40px; overflow-y: auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .logout-btn { background-color: #e74c3c; color: white; padding: 10px 18px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; }
        
        .metrics-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin-bottom: 35px; }
        .metric-card { background: white; padding: 20px; border-radius: 6px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); border-left: 4px solid #34495e; }
        .metric-card.doctors { border-left-color: #9b59b6; }
        .metric-card.patients { border-left-color: #2ecc71; }
        .metric-card.admins { border-left-color: #e67e22; }
        .metric-card h3 { color: #7f8c8d; font-size: 12px; text-transform: uppercase; margin-bottom: 5px; }
        .metric-card p { font-size: 26px; font-weight: bold; color: #2c3e50; }
        
        .status-alert { padding: 12px; margin-bottom: 25px; border-radius: 4px; font-weight: bold; color: white; font-size: 14px; text-align: center; }
        .data-panel { background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.04); padding: 25px; display: none; }
        .data-panel.active-panel { display: block; }
        .panel-section-wrapper { margin-bottom: 40px; background: #ffffff; border: 1px solid #eef2f5; border-radius: 6px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.01); }
        .panel-title { font-size: 16px; color: #2c3e50; margin-bottom: 15px; font-weight: 600; display: flex; align-items: center; gap: 8px; border-bottom: 2px solid #f4f7f6; padding-bottom: 8px; }
        
        table { width: 100%; border-collapse: collapse; margin-bottom: 10px; }
        th, td { padding: 12px 10px; text-align: left; border-bottom: 1px solid #eef2f5; font-size: 13px; }
        th { background-color: #f8f9fa; color: #34495e; font-weight: 600; }
        
        .role-badge { padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .role-ADMIN { background: #fff3e0; color: #e65100; }
        .role-DOCTOR { background: #f3e5f5; color: #4a148c; }
        .role-PATIENT { background: #e8f5e9; color: #1b5e20; }
        
        .action-btn { border: none; padding: 6px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; cursor: pointer; color: white; }
        .btn-status-active { background-color: #e67e22; }
        .btn-status-deactive { background-color: #2ecc71; }
        .btn-delete { background-color: #e74c3c; margin-left: 5px; }
        
        .spec-form { display: flex; gap: 6px; align-items: center; }
        .spec-input { padding: 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; width: 135px; }
        .btn-assign { background-color: #3498db; color: white; padding: 6px 10px; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; font-weight: bold; }
        
        .config-row { display: flex; justify-content: space-between; align-items: center; padding: 15px 0; border-bottom: 1px solid #f0f0f0; }
        .config-details h4 { color: #2c3e50; font-size: 15px; margin-bottom: 4px; }
        .config-details p { color: #7f8c8d; font-size: 13px; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h2>Admin Portal</h2>
        <button class="nav-tab active" onclick="switchTab('accounts', this)">Account Management</button>
        <button class="nav-tab" onclick="switchTab('config', this)">System Config</button>
        <button class="nav-tab" onclick="switchTab('audit', this)">Audit Tracking Logs</button>
    </div>

    <div class="main-content">
        <div class="header">
            <h1>Workspace Controller Dashboard</h1>
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

        <div id="accounts" class="data-panel active-panel">
            <div class="metrics-grid">
                <div class="metric-card"><h3>Total Directory</h3><p><%= totalUsers %></p></div>
                <div class="metric-card doctors"><h3>Approved Doctors</h3><p><%= activeDoctors %></p></div>
                <div class="metric-card patients"><h3>Registered Patients</h3><p><%= totalPatients %></p></div>
                <div class="metric-card admins"><h3>System Admins</h3><p><%= totalAdmins %></p></div>
            </div>

            <div class="panel-section-wrapper">
                <div class="panel-title">🩺 Medical Staff & Clinical Specialists</div>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Doctor Identity</th>
                            <th>Role</th>
                            <th>Medical Specialization Assignment</th>
                            <th>Consultation Fee</th>
                            <th>Available Hours</th>
                            <th>Status</th>
                            <th>Management Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% 
                        boolean hasDoctors = false;
                        for (Map<String, Object> userRow : systemUsers) {
                            if ("DOCTOR".equals((String) userRow.get("role"))) {
                                hasDoctors = true;
                                int userId = (Integer) userRow.get("userId");
                                boolean isActive = (Boolean) userRow.get("isActive");
                                String currentSpec = (String) userRow.get("specialization");
                                Double fee = (Double) userRow.get("consultationFee");
                                String hours = (String) userRow.get("availableHours");
                                if (currentSpec == null) currentSpec = "";
                                if (fee == null) fee = 0.0;
                                if (hours == null) hours = "Not Set";
                    %>
                        <tr>
                            <td><strong>#<%= userId %></strong></td>
                            <td><%= userRow.get("fullName") %><br><span style="font-size:11px; color:#7f8c8d;"><%= userRow.get("email") %></span></td>
                            <td><span class="role-badge role-DOCTOR">DOCTOR</span></td>
                            <td>
                                <form action="admin-action" method="POST" class="spec-form">
                                    <input type="hidden" name="action" value="assignDoctor">
                                    <input type="hidden" name="userId" value="<%= userId %>">
                                    <input type="text" name="specialization" class="spec-input" value="<%= currentSpec %>" placeholder="e.g. Cardiology" required>
                                    <button type="submit" class="btn-assign">Save</button>
                                </form>
                            </td>
                            <td>$<%= fee %></td>
                            <td><span style="font-size:12px; color:#34495e;"><%= hours %></span></td>
                            <td><strong style="color: <%= isActive ? "#2ecc71" : "#e74c3c" %>"><%= isActive ? "ACTIVE" : "SUSPENDED" %></strong></td>
                            <td>
                                <form action="admin-action" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="toggleStatus"><input type="hidden" name="userId" value="<%= userId %>"><input type="hidden" name="currentStatus" value="<%= isActive %>">
                                    <button type="submit" class="action-btn <%= isActive ? "btn-status-active" : "btn-status-deactive" %>"><%= isActive ? "Suspend" : "Activate" %></button>
                                </form>
                                <form action="admin-action" method="POST" style="display:inline;" onsubmit="return confirm('Purge account?');">
                                    <input type="hidden" name="action" value="delete"><input type="hidden" name="userId" value="<%= userId %>">
                                    <button type="submit" class="action-btn btn-delete">Purge</button>
                                </form>
                            </td>
                        </tr>
                    <%      }
                        }
                        if (!hasDoctors) { 
                    %>
                        <tr><td colspan="8" style="text-align:center; color:#95a5a6; padding:15px;">No medical staff records indexed.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div class="panel-section-wrapper">
                <div class="panel-title">🏥 Registered Patients Directory</div>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Patient Name & Contact Details</th>
                            <th>App Role</th>
                            <th>Specialization Context</th>
                            <th>Account Status</th>
                            <th>Management Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% 
                        boolean hasPatients = false;
                        for (Map<String, Object> userRow : systemUsers) {
                            if ("PATIENT".equals((String) userRow.get("role")) || userRow.get("role") == null) {
                                hasPatients = true;
                                int userId = (Integer) userRow.get("userId");
                                boolean isActive = (Boolean) userRow.get("isActive");
                    %>
                        <tr>
                            <td><strong>#<%= userId %></strong></td>
                            <td><%= userRow.get("fullName") %><br><span style="font-size:11px; color:#7f8c8d;"><%= userRow.get("email") %></span></td>
                            <td><span class="role-badge role-PATIENT">PATIENT</span></td>
                            <td><span style="color: #7f8c8d; font-style: italic;">Standard Patient</span></td>
                            <td><strong style="color: <%= isActive ? "#2ecc71" : "#e74c3c" %>"><%= isActive ? "ACTIVE" : "SUSPENDED" %></strong></td>
                            <td>
                                <form action="admin-action" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="toggleStatus"><input type="hidden" name="userId" value="<%= userId %>"><input type="hidden" name="currentStatus" value="<%= isActive %>">
                                    <button type="submit" class="action-btn <%= isActive ? "btn-status-active" : "btn-status-deactive" %>"><%= isActive ? "Suspend" : "Activate" %></button>
                                </form>
                                <form action="admin-action" method="POST" style="display:inline;" onsubmit="return confirm('Purge patient account?');">
                                    <input type="hidden" name="action" value="delete"><input type="hidden" name="userId" value="<%= userId %>">
                                    <button type="submit" class="action-btn btn-delete">Purge</button>
                                </form>
                            </td>
                        </tr>
                    <%      }
                        }
                        if (!hasPatients) { 
                    %>
                        <tr><td colspan="6" style="text-align:center; color:#95a5a6; padding:15px;">No patient records registered.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div class="panel-section-wrapper">
                <div class="panel-title">⚙️ System Administrators Core Group</div>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Administrator Name Reference</th>
                            <th>Security Role Authority</th>
                            <th>Specialization Domain</th>
                            <th>Account Status</th>
                            <th>Administrative Protection Access</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% 
                        for (Map<String, Object> userRow : systemUsers) {
                            if ("ADMIN".equals((String) userRow.get("role"))) {
                                int userId = (Integer) userRow.get("userId");
                    %>
                        <tr>
                            <td><strong>#<%= userId %></strong></td>
                            <td><%= userRow.get("fullName") %><br><span style="font-size:11px; color:#7f8c8d;"><%= userRow.get("email") %></span></td>
                            <td><span class="role-badge role-ADMIN">ADMIN</span></td>
                            <td><strong style="color: #2c3e50;">System Core Control</strong></td>
                            <td><span style="color:#2ecc71; font-weight:bold;">MASTER LIVE</span></td>
                            <td>
                                <span style="color: #95a5a6; font-size: 12px; font-style: italic; font-weight: 600;">🔒 Root Profile Protected</span>
                            </td>
                        </tr>
                    <%      }
                        } 
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="config" class="data-panel">
            <div class="panel-title">⚙️ Core Platform Framework Environment Configurations</div>
            <div class="config-row">
                <div class="config-details"><h4>Maintenance Window Blockage</h4><p>Suspends platform interactive access sequences globally for all users.</p></div>
                <form action="admin-action" method="POST" class="spec-form">
                    <input type="hidden" name="action" value="updateConfig"><input type="hidden" name="configKey" value="maintenance_mode">
                    <select name="configValue" class="spec-input"><option value="FALSE" <%= "FALSE".equals(configs.get("maintenance_mode")) ? "selected" : "" %>>Disabled (Live)</option><option value="TRUE" <%= "TRUE".equals(configs.get("maintenance_mode")) ? "selected" : "" %>>Enabled (Down)</option></select>
                    <button type="submit" class="btn-assign">Update</button>
                </form>
            </div>
            <div class="config-row">
                <div class="config-details"><h4>Allow New Registrations</h4><p>Toggle whether new visitors can sign up via register.jsp.</p></div>
                <form action="admin-action" method="POST" class="spec-form">
                    <input type="hidden" name="action" value="updateConfig"><input type="hidden" name="configKey" value="allow_registrations">
                    <select name="configValue" class="spec-input"><option value="TRUE" <%= "TRUE".equals(configs.get("allow_registrations")) ? "selected" : "" %>>Open</option><option value="FALSE" <%= "FALSE".equals(configs.get("allow_registrations")) ? "selected" : "" %>>Restricted</option></select>
                    <button type="submit" class="btn-assign">Update</button>
                </form>
            </div>
        </div>

        <div id="audit" class="data-panel">
            <div class="panel-title">📜 Real-time System Operation Audit Logs</div>
            <table>
                <thead>
                    <tr>
                        <th>Execution Timestamp</th>
                        <th>Actor Group</th>
                        <th>Action Protocol</th>
                        <th>Operation Description Metadata Details Log</th>
                    </tr>
                </thead>
                <tbody>
                <% if(auditLogs.isEmpty()) { %>
                    <tr><td colspan="4" style="text-align:center; color:#95a5a6;">No transactional records compiled as of this engine runtime loop execution checkpoint.</td></tr>
                <% } else { 
                    for(Map<String, String> log : auditLogs) { %>
                    <tr>
                        <td><span style="font-family: monospace; color:#7f8c8d;"><%= log.get("timestamp") %></span></td>
                        <td><strong style="color:#2980b9;"><%= log.get("actor") %></strong></td>
                        <td><span class="role-badge" style="background:#f1f2f6; color:#2c3e50;"><%= log.get("action") %></span></td>
                        <td><%= log.get("details") %></td>
                    </tr>
                <% } } %>
                </tbody>
            </table>
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