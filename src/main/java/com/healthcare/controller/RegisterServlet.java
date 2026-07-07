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
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        // Simple validation check for empty fields
        if (username == null || email == null || password == null || role == null ||
            username.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty() || role.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All form fields are strictly required.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Check if user already exists
        if (userDAO.isUserExists(username, email)) {
            request.setAttribute("errorMessage", "Username or Email is already taken.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Build User structure and attempt registration
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPassword(password);
        newUser.setRole(role);

        boolean isRegistered = userDAO.registerUser(newUser);

        if (isRegistered) {
            // Send directly to login page with success flag
            response.sendRedirect("login.jsp?success=true");
        } else {
            request.setAttribute("errorMessage", "Database registration error. Try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}