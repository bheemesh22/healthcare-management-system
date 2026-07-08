package com.healthcare.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.healthcare.dao.AdminDAO;
import com.healthcare.model.User;

@WebServlet("/admin-action")
public class AdminActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Secure access authorization guard check
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || !"ADMIN".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp?error=Unauthorized administrative routing access.");
            return;
        }

        String action = request.getParameter("action");
        
        try {
            if ("toggleStatus".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                boolean currentStatus = Boolean.parseBoolean(request.getParameter("currentStatus"));
                
                if (adminDAO.toggleUserStatus(userId, currentStatus)) {
                    response.sendRedirect("admin-dashboard.jsp?success=User account status updated successfully.");
                } else {
                    response.sendRedirect("admin-dashboard.jsp?error=Failed to alter target user system status.");
                }
                
            } else if ("delete".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                
                if (adminDAO.deleteUser(userId)) {
                    response.sendRedirect("admin-dashboard.jsp?success=User permanently purged from database records.");
                } else {
                    response.sendRedirect("admin-dashboard.jsp?error=Failed to completely remove target profile entry.");
                }
                
            } else if ("assignDoctor".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                String specialization = request.getParameter("specialization");
                
                if (specialization == null || specialization.trim().isEmpty()) {
                    response.sendRedirect("admin-dashboard.jsp?error=Specialization field value cannot be left empty.");
                    return;
                }
                
                if (adminDAO.provisionDoctorProfile(userId, specialization)) {
                    response.sendRedirect("admin-dashboard.jsp?success=Doctor medical profile directory verified and linked successfully.");
                } else {
                    response.sendRedirect("admin-dashboard.jsp?error=Failed to map doctor specialization schema parameters.");
                }
            } else {
                response.sendRedirect("admin-dashboard.jsp?error=Invalid action parameter signature.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-dashboard.jsp?error=An unexpected administrative interface processing fault occurred.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("admin-dashboard.jsp");
    }
}