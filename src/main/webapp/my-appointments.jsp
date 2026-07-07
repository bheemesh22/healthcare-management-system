<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%
    // Session Validation Guard
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
    <title>My Scheduled Appointments</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; padding: 40px; color: #2c3e50; }
        .container { max-width: 950px; margin: 0 auto; }
        .header-area { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .back-btn { background-color: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; font-weight: bold; }
        .back-btn:hover { background-color: #2980b9; }
        
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #e0e0e0; font-size: 14px; }
        th { background-color: #3498db; color: white; font-weight: 600; }
        tr:hover { background-color: #f9f9f9; }
        
        .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; text-transform: uppercase; }
        .badge-pending { background-color: #ffeaa7; color: #b7791f; }
        .badge-confirmed { background-color: #badc58; color: #6ab04c; }
        .no-records { text-align: center; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); color: #7f8c8d; font-style: italic; }
    </style>
</head>
<body>

<div class="container">
    <div class="header-area">
        <h1>🗓️ My Scheduled Consultation History</h1>
        <a href="patient-dashboard.jsp" class="back-btn">← Back to Dashboard</a>
    </div>

    <%
        if (patientId == null) {
    %>
        <div class="no-records">Error: Patient identity context profile mapping could not be resolved.</div>
    <%
        } else {
            try {
                conn = com.healthcare.util.DBConnection.getConnection();
                
                // Fetch appointments linked to this patient and join with users to pull the doctor's name
                String sql = "SELECT a.appointment_id, a.appointment_date, a.time_slot, a.symptoms, a.status, u.username AS doctor_name " +
                             "FROM appointments a " +
                             "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                             "JOIN users u ON d.user_id = u.user_id " +
                             "WHERE a.patient_id = ? " +
                             "ORDER BY a.appointment_date DESC";
                             
                ps = conn.prepareStatement(sql);
                ps.setInt(1, patientId);
                rs = ps.executeQuery();

                if (!rs.isBeforeFirst()) {
    %>
                    <div class="no-records">You have not scheduled or requested any consultation appointments yet.</div>
    <%
                } else {
    %>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Doctor Reference</th>
                                <th>Consultation Date</th>
                                <th>Time Window Slot</th>
                                <th>Symptoms Noted</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            while (rs.next()) {
                                String status = rs.getString("status");
                        %>
                            <tr>
                                <td><strong>#<%= rs.getInt("appointment_id") %></strong></td>
                                <td>Dr. <%= rs.getString("doctor_name") %></td>
                                <td><%= rs.getDate("appointment_date") %></td>
                                <td><%= rs.getString("time_slot") %></td>
                                <td><%= rs.getString("symptoms") %></td>
                                <td>
                                    <span class="badge <%= "CONFIRMED".equalsIgnoreCase(status) ? "badge-confirmed" : "badge-pending" %>">
                                        <%= status %>
                                    </span>
                                </td>
                            </tr>
                        <%
                            }
                        %>
                        </tbody>
                    </table>
    <%
                }
            } catch (SQLException e) {
                e.printStackTrace();
    %>
                <div class="no-records" style="color: #e74c3c;">An engineering error occurred loading records from the database pipeline.</div>
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