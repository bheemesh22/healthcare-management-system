<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="com.healthcare.model.MedicalRecord" %>
<%@ page import="com.healthcare.dao.RecordsDAO" %>
<%@ page import="java.util.List" %>
<%
    // Session Guard Validation
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"PATIENT".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    RecordsDAO recordsDAO = new RecordsDAO();
    List<MedicalRecord> historyRecords = recordsDAO.getRecordsByUserId(currentUser.getUserId());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Electronic Medical Health Records</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; display: flex; min-height: 100vh; }
        
        .sidebar { width: 260px; background-color: #2c3e50; color: white; padding: 30px 20px; }
        .sidebar h2 { margin-bottom: 30px; font-size: 22px; text-align: center; border-bottom: 2px solid #34495e; padding-bottom: 10px; }
        .sidebar a { display: block; color: #bdc3c7; padding: 12px 15px; text-decoration: none; margin-bottom: 8px; border-radius: 4px; transition: 0.3s; }
        .sidebar a:hover, .sidebar a.active { background-color: #3498db; color: white; }
        
        .main-content { flex: 1; padding: 40px; overflow-y: auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .back-btn { background-color: #7f8c8d; color: white; padding: 10px 18px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; }
        
        .status-alert { padding: 12px; margin-bottom: 25px; border-radius: 4px; font-weight: bold; color: white; text-align: center; font-size: 14px; }
        
        .layout-grid { display: grid; grid-template-columns: 1fr 2fr; gap: 30px; }
        .card-panel { background: white; border-radius: 8px; padding: 25px; box-shadow: 0 4px 10px rgba(0,0,0,0.04); height: fit-content; }
        .panel-title { font-size: 18px; color: #2c3e50; margin-bottom: 20px; font-weight: 600; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        
        /* Form elements */
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 6px; color: #34495e; font-size: 14px; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; outline: none; }
        .btn-submit { width: 100%; background-color: #2ecc71; color: white; border: none; padding: 12px; border-radius: 4px; font-weight: bold; font-size: 15px; cursor: pointer; transition: 0.2s; }
        .btn-submit:hover { background-color: #27ae60; }
        
        /* Table Styling */
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 14px 12px; text-align: left; border-bottom: 1px solid #eef2f5; font-size: 14px; }
        th { background-color: #f8f9fa; color: #34495e; font-weight: 600; }
        .btn-download { background-color: #3498db; color: white; padding: 6px 12px; text-decoration: none; border-radius: 4px; font-size: 12px; font-weight: bold; display: inline-block; }
        .btn-download:hover { background-color: #2980b9; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h2>HealthSync AI</h2>
        <a href="patient-dashboard.jsp">Dashboard Home</a>
        <a href="my-appointments.jsp">My Appointments</a>
        <a href="medical-records.jsp" class="active">Medical Records</a>
        <a href="view-prescriptions.jsp">Prescriptions</a>
        <a href="profile-settings.jsp">Settings Profile</a>
    </div>

    <div class="main-content">
        <div class="header">
            <h1>📑 Electronic Health Records Workspace</h1>
            <a href="patient-dashboard.jsp" class="back-btn">← Back to Dashboard</a>
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

        <div class="layout-grid">
            
            <div class="card-panel">
                <div class="panel-title">📤 Archive New Report</div>
                <form action="uploadRecord" method="POST" enctype="multipart/form-data">
                    <div class="form-group">
                        <label>Report Identification / Title Name</label>
                        <input type="text" name="reportName" class="form-control" placeholder="e.g., Lipid Profile Blood Test, Chest X-Ray" required>
                    </div>
                    <div class="form-group">
                        <label>Select Document File (PDF, Image)</label>
                        <input type="file" name="documentFile" class="form-control" accept=".pdf, image/*" required>
                    </div>
                    <button type="submit" class="btn-submit">Upload to Vault</button>
                </form>
            </div>
            
            <div class="card-panel">
                <div class="panel-title">🗂️ Stored Diagnostic Reports Archive Repository</div>
                <table>
                    <thead>
                        <tr>
                            <th>Record ID</th>
                            <th>Document Title Naming</th>
                            <th>Uploaded Timestamp Date</th>
                            <th>Action Payload</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (historyRecords == null || historyRecords.isEmpty()) { %>
                        <tr>
                            <td colspan="4" style="text-align: center; color: #95a5a6; font-style: italic; padding: 30px;">
                                No external diagnostic reports or clinical records uploaded to your index.
                            </td>
                        </tr>
                    <% } else {
                        for (MedicalRecord record : historyRecords) {
                    %>
                        <tr>
                            <td><strong>#<%= record.getRecordId() %></strong></td>
                            <td><%= record.getReportName() %></td>
                            <td style="color: #7f8c8d;"><%= record.getUploadedAt() %></td>
                            <td>
                                <a href="<%= record.getFilePath() %>" target="_blank" class="btn-download">⬇️ Download / View</a>
                            </td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
            
        </div>
    </div>

</body>
</html>