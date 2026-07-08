<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="com.healthcare.dao.AdminDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    // Validate administrative privilege parameters
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"ADMIN".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp?error=Session expired or authorization restricted.");
        return;
    }

    AdminDAO dao = new AdminDAO();
    List<Map<String, Object>> systemUsers = dao.getAllUsersWithDetails();
    
    // Compute quick dashboard analytics totals
    int totalUsers = systemUsers.size();
    int activeDoctors = 0;
    int totalPatients = 0;
    for (Map<String, Object> u : systemUsers) {
        String role = (String) u.get("role");
        if ("DOCTOR".equals(role)) activeDoctors++;
        else if ("PATIENT".equals(role)) totalPatients++;
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
        .sidebar a { display: block; color: #bdc3c7; padding: 12px 15px; text-decoration: none; margin-bottom: 8px; border-radius: 4px; font-weight: 500; }
        .sidebar a.active, .sidebar a:hover { background-color: #3498db; color: white; }
        .main-content { flex: 1; padding: 40px; overflow-y: auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .logout-btn { background-color: #e74c3c; color: white; padding: 10px 18px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; }
        .logout-btn:hover { background-color: #c0392b; }
        
        .metrics-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 35px; }
        .metric-card { background: white; padding: 20px; border-radius: 6px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); border-left: 4px solid #3498db; }
        .metric-card.doctors { border-left-color: #9b59b6; }
        .metric-card.patients { border-left-color: #2ecc71; }
        .metric-card h3 { color: #7f8c8d; font-size: 13px; text-transform: uppercase; margin-bottom: 5px; }
        .metric-card p { font-size: 28px; font-weight: bold; color: #2c3e50; }
        
        .status-alert { padding: 12px; margin-bottom: 25px; border-radius: 4px; font-weight: bold; color: white; font-size: 14px; text-align: center; }
        
        .data-panel { background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.04); padding: 25px; }
        .panel-title { font-size: 18px; color: #2c3e50; margin-bottom: 20px; font-weight: 600; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 14px 12px; text-align: left; border-bottom: 1px solid #eef2f5; font-size: 14px; }
        th { background-color: #f8f9fa; color: #34495e; font-weight: 600; }
        
        .role-badge { padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .role-ADMIN { background: #e3f2fd; color: #0d47a1; }
        .role-DOCTOR { background: #f3e5f5; color: #4a148c; }
        .role-PATIENT { background: #e8f5e9; color: #1b5e20; }
        
        .action-btn { border: none; padding: 6px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; cursor: pointer; color: white; text-decoration: none; display: inline-block; }
        .btn-status-active { background-color: #e67e22; }
        .btn-status-deactive { background-color: #2ecc71; }
        .btn-delete { background-color: #e74c3c; margin-left: 5px; }
        .btn-delete:hover { background-color: #c0392b; }
        
        .spec-form { display: flex; gap: 6px; align-items: center; }
        .spec-input { padding: 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; width: 130px; }
        .btn-assign { background-color: #3498db; color: white; padding: 6px 10px; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; font-weight: bold; }
        .btn-assign:hover { background-color: #2980b9; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h2>Admin Portal</h2>
        <a href="admin-dashboard.jsp" class="active">Account Management</a>
        <a href="#">System Config</a>
        <a href="#">Audit Tracking Logs</a>
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

        <div class="metrics-grid">
            <div class="metric-card">
                <h3>Total System Registries</h3>
                <p><%= totalUsers %></p>
            </div>
            <div class="metric-card doctors">
                <h3>Active Approved Doctors</h3>
                <p><%= activeDoctors %></p>
            </div>
            <div class="metric-card patients">
                <h3>Registered Patients</h3>
                <p><%= totalPatients %></p>
            </div>
        </div>

        <div class="data-panel">
            <div class="panel-title">👥 Complete System User Directory Roster</div>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>User Identity Profile</th>
                        <th>Email Contact Path</th>
                        <th>App Role</th>
                        <th>Account Status</th>
                        <th>Doctor Specialization Matrix Assignment</th>
                        <th>Management Control Operators</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    for (Map<String, Object> userRow : systemUsers) {
                        int userId = (Integer) userRow.get("userId");
                        boolean isActive = (Boolean) userRow.get("isActive");
                        String role = (String) userRow.get("role");
                        String currentSpec = (String) userRow.get("specialization");
                        if (currentSpec == null) {
                            currentSpec = "Not Assigned / Patient";
                        }
                %>
                    <tr>
                        <td><strong>#<%= userId %></strong></td>
                        <td><%= userRow.get("fullName") %></td>
                        <td><%= userRow.get("email") %></td>
                        <td><span class="role-badge role-<%= role %>"><%= role %></span></td>
                        <td>
                            <strong style="color: <%= isActive ? "#2ecc71" : "#e74c3c" %>">
                                <%= isActive ? "ACTIVE" : "SUSPENDED" %>
                            </strong>
                        </td>
                        <td>
                            <% if ("DOCTOR".equals(role)) { %>
                                <form action="admin-action" method="POST" class="spec-form">
                                    <input type="hidden" name="action" value="assignDoctor">
                                    <input type="hidden" name="userId" value="<%= userId %>">
                                    <input type="text" name="specialization" class="spec-input" 
                                           placeholder="e.g., Cardiology" value="<%= "Not Assigned / Patient".equals(currentSpec) ? "" : currentSpec %>" required>
                                    <button type="submit" class="btn-assign">Save</button>
                                </form>
                            <% } else { %>
                                <span style="color: #95a5a6; font-size: 13px;"><%= currentSpec %></span>
                            <% } %>
                        </td>
                        <td>
                            <form action="admin-action" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="toggleStatus">
                                <input type="hidden" name="userId" value="<%= userId %>">
                                <input type="hidden" name="currentStatus" value="<%= isActive %>">
                                <button type="submit" class="action-btn <%= isActive ? "btn-status-active" : "btn-status-deactive" %>">
                                    <%= isActive ? "Suspend" : "Activate" %>
                                </button>
                            </form>

                            <form action="admin-action" method="POST" style="display:inline;" 
                                  onsubmit="return confirm('Are you absolutely certain you want to permanently delete this user profile account?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="userId" value="<%= userId %>">
                                <button type="submit" class="action-btn btn-delete">Purge</button>
                            </form>
                        </td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>