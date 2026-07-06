package com.healthcare.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.healthcare.dao.UserDAO;
import com.healthcare.dao.UserDAOImpl;
import com.healthcare.model.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        // Initialize the data layer handler
        this.userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Direct address hits to /login route directly over to the login interface view
        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Gather form input credentials
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 2. Validate field presence
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Username and Password cannot be blank.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // 3. Authenticate user records against the database
        User verifiedUser = userDAO.loginUser(username.trim(), password);

        // 4. Act on authentication result
        if (verifiedUser != null) {
            // Authentication Success -> Initialize an active secure session tracking object
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", verifiedUser);
            session.setAttribute("userRole", verifiedUser.getRole());

            // 5. Route user based on their specific account security permission tier (Role)
            String role = verifiedUser.getRole();
            if ("ADMIN".equals(role)) {
                response.sendRedirect("admin-dashboard.jsp");
            } else if ("DOCTOR".equals(role)) {
                response.sendRedirect("doctor-dashboard.jsp");
            } else if ("PATIENT".equals(role)) {
                response.sendRedirect("patient-dashboard.jsp");
            } else {
                // Fallback catch if role mapping is anomalous
                response.sendRedirect("index.jsp");
            }
        } else {
            // Authentication Failure -> Return back to login with clean error flags
            request.setAttribute("errorMessage", "Invalid Username or Password. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}