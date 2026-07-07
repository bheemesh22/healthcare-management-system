<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Healthcare System - User Login</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .login-container { background-color: #ffffff; padding: 30px 40px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); width: 100%; max-width: 400px; }
        h2 { text-align: center; color: #2c3e50; margin-bottom: 24px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; margin-bottom: 6px; color: #34495e; font-weight: 600; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-size: 14px; }
        .form-group input:focus { border-color: #3498db; outline: none; }
        .btn-submit { width: 100%; padding: 12px; background-color: #2ecc71; border: none; border-radius: 4px; color: white; font-size: 16px; font-weight: bold; cursor: pointer; transition: background-color 0.2s ease; }
        .btn-submit:hover { background-color: #27ae60; }
        .error-message { background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 14px; border: 1px solid #f5c6cb; text-align: center; }
        .success-message { background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 14px; border: 1px solid #c3e6cb; text-align: center; }
        .register-link { text-align: center; margin-top: 15px; font-size: 14px; }
        .register-link a { color: #3498db; text-decoration: none; }
        .register-link a:hover { text-decoration: underline; }
    </style>
</head>
<body>

<div class="login-container">
    <h2>User Login</h2>

    <%-- Catch redirected success alerts --%>
    <% 
        String successMsg = request.getParameter("success");
        String regSuccess = request.getParameter("registrationSuccess");
        if (successMsg != null) {
    %>
        <div class="success-message"><%= successMsg %></div>
    <% 
        } else if ("true".equals(regSuccess)) {
    %>
        <div class="success-message">Account created successfully! Please sign in.</div>
    <% 
        } 
    %>

    <%-- Catch parameter error alerts forwarded from the servlet --%>
    <% 
        String errorMsg = request.getParameter("error");
        if (errorMsg != null) {
    %>
        <div class="error-message"><%= errorMsg %></div>
    <% 
        } 
    %>

    <%-- Form point map --%>
    <form action="${pageContext.request.contextPath}/login" method="POST">
        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" placeholder="Enter your email address" required>
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="Enter your password" required>
        </div>

        <button type="submit" class="btn-submit">Login</button>
    </form>

    <div class="register-link">
        Don't have an account yet? <a href="register.jsp">Register here</a>
    </div>
</div>

</body>
</html>