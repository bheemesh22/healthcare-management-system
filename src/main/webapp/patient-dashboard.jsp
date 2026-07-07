<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"PATIENT".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Patient Medical Dashboard</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; display: flex; min-height: 100vh; }
        .sidebar { width: 260px; background-color: #2c3e50; color: white; padding: 30px 20px; }
        .sidebar h2 { margin-bottom: 30px; font-size: 22px; text-align: center; border-bottom: 2px solid #34495e; padding-bottom: 10px; }
        .sidebar a { display: block; color: #bdc3c7; padding: 12px 15px; text-decoration: none; margin-bottom: 8px; border-radius: 4px; transition: 0.3s; }
        .sidebar a:hover, .sidebar a.active { background-color: #3498db; color: white; }
        .main-content { flex: 1; padding: 40px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .header h1 { color: #2c3e50; }
        .logout-btn { background-color: #e74c3c; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; font-weight: bold; }
        .dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 25px; margin-bottom: 40px; }
        .card { background: white; border-radius: 8px; padding: 25px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border-top: 4px solid #3498db; display: flex; flex-direction: column; justify-content: space-between; }
        .card h3 { color: #2c3e50; margin-bottom: 15px; }
        .card p { color: #7f8c8d; font-size: 14px; line-height: 1.5; margin-bottom: 15px; }
        
        .btn-link { display: inline-block; background: #3498db; color: white; padding: 8px 14px; text-decoration: none; border-radius: 4px; font-size: 13px; font-weight: bold; align-self: flex-start; }
        .btn-link:hover { background: #2980b9; }

        .status-alert { padding: 12px; margin-bottom: 20px; border-radius: 4px; font-weight: bold; color: white; }
        
        /* Interactive Chatbot Interface Styling */
        .chat-container { background: white; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); width: 100%; max-width: 500px; height: 450px; display: flex; flex-direction: column; overflow: hidden; border: 1px solid #e0e0e0; margin-top: 20px; }
        .chat-header { background: #3498db; color: white; padding: 15px; font-weight: bold; display: flex; align-items: center; justify-content: space-between; }
        .chat-box { flex: 1; padding: 15px; overflow-y: auto; background: #f9f9f9; display: flex; flex-direction: column; gap: 10px; }
        .message { max-width: 75%; padding: 10px 14px; border-radius: 15px; font-size: 14px; line-height: 1.4; }
        .user-msg { background: #3498db; color: white; align-self: flex-end; border-bottom-right-radius: 2px; }
        .ai-msg { background: #e1e8ed; color: #2c3e50; align-self: flex-start; border-bottom-left-radius: 2px; }
        .chat-input-area { display: flex; border-top: 1px solid #e0e0e0; padding: 10px; background: white; }
        .chat-input-area input { flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 4px; outline: none; }
        .chat-input-area button { background: #3498db; color: white; border: none; padding: 0 15px; margin-left: 8px; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .chat-input-area button:hover { background: #2980b9; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h2>HealthSync AI</h2>
        <a href="#" class="active">Dashboard Home</a>
        <a href="#">My Appointments</a>
        <a href="#">Medical Records</a>
        <a href="#">Prescriptions</a>
        <a href="#">Settings Profile</a>
    </div>

    <div class="main-content">
        <div class="header">
            <h1>Welcome, <%= currentUser.getUsername() %>!</h1>
            <a href="logout" class="logout-btn">Secure Logout</a>
        </div>

        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) {
        %>
            <div class="status-alert" style="background-color: #2ecc71;"><%= successMsg %></div>
        <% } if (errorMsg != null) { %>
            <div class="status-alert" style="background-color: #e74c3c;"><%= errorMsg %></div>
        <% } %>

        <div class="dashboard-grid">
            <div class="card">
                <div>
                    <h3>Schedule New Appointment</h3>
                    <p>Connect with our verified specialized clinic physicians or view your upcoming active appointment sessions instantly.</p>
                </div>
                <a href="book-appointment.jsp" class="btn-link">Book Now →</a>
            </div>
            <div class="card">
                <div>
                    <h3>Electronic Health Records</h3>
                    <p>Review diagnostic lab test metrics, past clinical summary releases, and historical profile telemetry updates safely.</p>
                </div>
                <a href="#" class="btn-link">View Records</a>
            </div>
            <div class="card">
                <div>
                    <h3>Active Prescriptions</h3>
                    <p>Track your medication schedules, clinical prescription dosages, and refill approval timelines directly.</p>
                </div>
                <a href="#" class="btn-link">View Details</a>
            </div>
        </div>

        <h2>💬 Ask HealthSync AI Assistant</h2>
        <div class="chat-container">
            <div class="chat-header">
                <span>Medical AI Consultation Agent</span>
                <span style="font-size: 11px; background: rgba(255,255,255,0.2); padding: 3px 6px; border-radius: 3px;">Online</span>
            </div>
            <div class="chat-box" id="chatBox">
                <div class="message ai-msg">Hello <%= currentUser.getUsername() %>, how can I help monitor or explain your symptoms today?</div>
            </div>
            <div class="chat-input-area">
                <input type="text" id="userInput" placeholder="Ask about symptoms, drugs, or exercises..." onkeypress="handleKeyPress(event)">
                <button type="button" onclick="sendMessage()">Send</button>
            </div>
        </div>
    </div>

    <script>
        function handleKeyPress(event) {
            if (event.key === "Enter") {
                sendMessage();
            }
        }

        function sendMessage() {
            const inputField = document.getElementById("userInput");
            const messageText = inputField.value.trim();
            if (messageText === "") return;

            const chatBox = document.getElementById("chatBox");

            const userDiv = document.createElement("div");
            userDiv.className = "message user-msg";
            userDiv.textContent = messageText;
            chatBox.appendChild(userDiv);
            
            inputField.value = "";
            chatBox.scrollTop = chatBox.scrollHeight;

            fetch("chatbot", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ message: messageText })
            })
            .then(response => response.json())
            .then(data => {
                const aiDiv = document.createElement("div");
                aiDiv.className = "message ai-msg";
                aiDiv.textContent = data.reply;
                chatBox.appendChild(aiDiv);
                chatBox.scrollTop = chatBox.scrollHeight;
            })
            .catch(error => {
                console.error("Error:", error);
                const errorDiv = document.createElement("div");
                errorDiv.className = "message ai-msg";
                errorDiv.textContent = "Unable to process message at this moment.";
                chatBox.appendChild(errorDiv);
            });
        }
    </script>
</body>
</html>