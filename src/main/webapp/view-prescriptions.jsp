<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%
    // Ensure the user is authenticated and possesses the correct PATIENT role
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"PATIENT".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer patientId = (Integer) session.getAttribute("patientId");
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Medical Prescriptions</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; padding: 40px; color: #2c3e50; }
        .container { max-width: 900px; margin: 0 auto; }
        .header-area { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .back-btn { background-color: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; font-weight: bold; }
        .back-btn:hover { background-color: #2980b9; }
        .prescription-card { background: white; border-radius: 8px; padding: 25px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-bottom: 25px; border-left: 5px solid #2ecc71; }
        .prescription-header { display: flex; justify-content: space-between; border-bottom: 1px dashed #e0e0e0; padding-bottom: 10px; margin-bottom: 15px; }
        .doctor-name { font-size: 18px; font-weight: bold; color: #2c3e50; }
        .date-stamp { color: #7f8c8d; font-size: 14px; }
        .section-title { font-weight: bold; font-size: 14px; color: #34495e; text-transform: uppercase; margin-top: 12px; margin-bottom: 4px; }
        .section-content { font-size: 15px; line-height: 1.5; color: #555; background: #f9f9f9; padding: 10px; border-radius: 4px; }
        .no-records { text-align: center; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); color: #7f8c8d; font-style: italic; }
    </style>
</head>
<body>

<div class="container">
    <div class="header-area">
        <h1>📋 My Active Prescriptions</h1>
        <a href="patient-dashboard.jsp" class="back-btn">← Back to Dashboard</a>
    </div>

    <%
        if (patientId == null) {
    %>
        <div class="no-records">Error: Patient session identity profile mapping could not be resolved.</div>
    <%
        } else {
            try {
                conn = com.healthcare.util.DBConnection.getConnection();
                
                String sql = "SELECT p.prescription_id, p.diagnosis, p.doctor_notes, p.prescribed_medicines, p.created_at, u.username AS doctor_name " +
                             "FROM prescriptions p " +
                             "JOIN appointments a ON p.appointment_id = a.appointment_id " +
                             "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                             "JOIN users u ON d.user_id = u.user_id " +
                             "WHERE a.patient_id = ? " +
                             "ORDER BY p.created_at DESC";
                             
                ps = conn.prepareStatement(sql);
                ps.setInt(1, patientId);
                rs = ps.executeQuery();

                boolean hasPrescriptions = false;
                while (rs.next()) {
                    hasPrescriptions = true;
    %>
                    <div class="prescription-card">
                        <div class="prescription-header">
                            <span class="doctor-name">Issued by: Dr. <%= rs.getString("doctor_name") %></span>
                            <span class="date-stamp">Date: <%= rs.getTimestamp("created_at") %></span>
                        </div>
                        
                        <div class="section-title">Clinical Diagnosis</div>
                        <div class="section-content"><strong><%= rs.getString("diagnosis") %></strong></div>
                        
                        <div class="section-title">Prescribed Medications & Dosages</div>
                        <div class="section-content" style="white-space: pre-line;"><%= rs.getString("prescribed_medicines") %></div>
                        
                        <% if (rs.getString("doctor_notes") != null && !rs.getString("doctor_notes").trim().isEmpty()) { %>
                            <div class="section-title">Additional Doctor Advice</div>
                            <div class="section-content" style="white-space: pre-line;"><%= rs.getString("doctor_notes") %></div>
                        <% } %>
                    </div>
    <%
                }
                if (!hasPrescriptions) {
    %>
                    <div class="no-records">No authorized medical prescriptions or clinical treatment histories found on your profile.</div>
    <%
                }
            } catch (SQLException e) {
                e.printStackTrace();
    %>
                <div class="no-records" style="color: #e74c3c;">An error occurred while loading your prescription documents from the database.</div>
    <%
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        }
    %>
</div>

</body>
</html>