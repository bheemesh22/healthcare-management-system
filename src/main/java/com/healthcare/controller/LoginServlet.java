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
        this.userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please fill in both username and password fields.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // Verify credentials against database
        User validatedUser = userDAO.validateUser(username, password);

        if (validatedUser != null) {
            // Set up clean browser session tracking structures
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", validatedUser);
            session.setAttribute("userRole", validatedUser.getRole());

            // Route user based on their specific account role
            String role = validatedUser.getRole();
            if ("PATIENT".equals(role)) {
                response.sendRedirect("patient-dashboard.jsp");
            } else if ("DOCTOR".equals(role)) {
                response.sendRedirect("doctor-dashboard.jsp");
            } else if ("ADMIN".equals(role)) {
                response.sendRedirect("admin-dashboard.jsp");
            } else {
                response.sendRedirect("login.jsp");
            }
        } else {
            request.setAttribute("errorMessage", "Invalid Username or Password. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}