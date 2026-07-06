package com.healthcare.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.healthcare.dao.UserDAO;
import com.healthcare.dao.UserDAOImpl;
import com.healthcare.model.User;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L; // Fixes the serialization warning noted earlier
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        // Initialize the DAO implementation instance
        this.userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // If a user tries to access /register directly via URL, redirect them to the signup page
        response.sendRedirect("register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Extract Form Input Parameters
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role"); // ADMIN, DOCTOR, PATIENT

        // 2. Basic Validation: Ensure no field is empty
        if (username == null || username.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            role == null || role.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "All registration fields are required.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // 3. Encapsulate Data into the User Model Object
        User newUser = new User(username.trim(), email.trim(), password, role.toUpperCase());

        // 4. Delegate to DAO for Database Insertion
        boolean isRegistered = userDAO.registerUser(newUser);

        // 5. Route the User Based on Success or Failure
        if (isRegistered) {
            // Registration success -> Send to login page with a success flag
            response.sendRedirect("login.jsp?registrationSuccess=true");
        } else {
            // Registration failed (e.g., duplicate username/email) -> Return to registration form
            request.setAttribute("errorMessage", "Registration failed. Username or Email might already be taken.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}