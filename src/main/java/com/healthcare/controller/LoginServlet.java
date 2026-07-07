package com.healthcare.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.healthcare.model.User;
import com.healthcare.util.DBConnection;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Basic input guard checks
        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=Email and password are required fields.");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            
            // 1. Authenticate against the core users table
            String userSql = "SELECT user_id, full_name, email, role, is_active FROM users WHERE email = ? AND password = ?";
            ps = conn.prepareStatement(userSql);
            ps.setString(1, email.trim());
            ps.setString(2, password); // Note: Update to hashing verification if passwords are encrypted
            
            rs = ps.executeQuery();

            if (rs.next()) {
                // Instantiate the user entity context model
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));

                // Check if account administrative status allows platform operations
                if (!user.isActive()) {
                    response.sendRedirect("login.jsp?error=This user account has been deactivated.");
                    return;
                }

                // 2. Establish valid session storage
                HttpSession session = request.getSession(true);
                session.setAttribute("currentUser", user);
                session.setAttribute("userRole", user.getRole());

                // Close original user statement to safely reuse parameters
                ps.close();
                rs.close();

                // 3. Dynamic sub-profile index lookup to link relational keys to session state
                if ("PATIENT".equals(user.getRole())) {
                    String patientSql = "SELECT patient_id FROM patients WHERE user_id = ?";
                    ps = conn.prepareStatement(patientSql);
                    ps.setInt(1, user.getUserId());
                    rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        session.setAttribute("patientId", rs.getInt("patient_id"));
                    }
                    response.sendRedirect("patient-dashboard.jsp");
                    
                } else if ("DOCTOR".equals(user.getRole())) {
                    String doctorSql = "SELECT doctor_id FROM doctors WHERE user_id = ?";
                    ps = conn.prepareStatement(doctorSql);
                    ps.setInt(1, user.getUserId());
                    rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        session.setAttribute("doctorId", rs.getInt("doctor_id"));
                    }
                    response.sendRedirect("doctor-dashboard.jsp");
                    
                } else if ("ADMIN".equals(user.getRole())) {
                    response.sendRedirect("admin-dashboard.jsp");
                } else {
                    response.sendRedirect("login.jsp?error=Invalid application access role assigned.");
                }

            } else {
                // Invalid credentials fallback routing rule
                response.sendRedirect("login.jsp?error=Invalid email or mismatching password sequence.");
            }

        } catch (SQLException e) {
            System.err.println("❌ Critical runtime data processing error during login workflow processing:");
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Database processing sub-system error occurred.");
        } finally {
            // Clean resources up to avoid memory overhead leaks
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}