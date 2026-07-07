package com.healthcare.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Obtain the active session context if it exists
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Remove specific credentials explicitly
            session.removeAttribute("currentUser");
            session.removeAttribute("userRole");
            session.removeAttribute("patientId");
            session.removeAttribute("doctorId");
            
            // Invalidate the session context entirely
            session.invalidate();
        }
        
        // Prevent browser caching of protected dashboard views
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies
        
        // Redirect cleanly to login interface with explicit logging context
        response.sendRedirect("login.jsp?success=You have been successfully and securely logged out.");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}