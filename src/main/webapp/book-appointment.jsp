<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.healthcare.model.User" %>
<%
    // Ensure the user is authenticated and is a patient before rendering the form
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
    <title>Book a Medical Appointment</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 0; }
        body { background-color: #f4f7f6; padding: 40px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .form-container { background: white; padding: 35px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.08); width: 100%; max-width: 550px; border-top: 5px solid #3498db; }
        h2 { color: #2c3e50; margin-bottom: 25px; text-align: center; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #34495e; font-weight: 600; font-size: 14px; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 12px; border: 1px solid #ccc; border-radius: 4px; font-size: 15px; outline: none; transition: 0.2s; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: #3498db; }
        textarea { resize: vertical; height: 100px; }
        .btn-submit { width: 100%; background-color: #3498db; color: white; border: none; padding: 14px; border-radius: 4px; font-size: 16px; font-weight: bold; cursor: pointer; transition: 0.3s; margin-top: 10px; }
        .btn-submit:hover { background-color: #2980b9; }
        .back-link { display: block; text-align: center; margin-top: 20px; color: #7f8c8d; text-decoration: none; font-size: 14px; }
        .back-link:hover { color: #3498db; }
    </style>
</head>
<body>

<div class="form-container">
    <h2>Schedule an Appointment</h2>
    
    <form action="bookAppointment" method="POST">
        
        <div class="form-group">
            <label for="doctorId">Select Specialist Doctor</label>
            <select name="doctorId" id="doctorId" required>
                <option value="">-- Choose a Professional Specialist --</option>
                <option value="1">Dr. B. Venkat (Cardiology)</option>
                <option value="2">Dr. Anil Kumar (General Medicine)</option>
            </select>
        </div>

        <div class="form-group">
            <label for="appointmentDate">Preferred Date</label>
            <input type="date" name="appointmentDate" id="appointmentDate" required>
        </div>

        <div class="form-group">
            <label for="timeSlot">Available Time Slot</label>
            <select name="timeSlot" id="timeSlot" required>
                <option value="">-- Select a Session Time Window --</option>
                <option value="09:00 AM - 10:00 AM">09:00 AM - 10:00 AM</option>
                <option value="10:30 AM - 11:30 AM">10:30 AM - 11:30 AM</option>
                <option value="12:00 PM - 01:00 PM">12:00 PM - 01:00 PM</option>
                <option value="03:00 PM - 04:00 PM">03:00 PM - 04:00 PM</option>
                <option value="04:30 PM - 05:30 PM">04:30 PM - 05:30 PM</option>
            </select>
        </div>

        <div class="form-group">
            <label for="symptoms">Describe Current Symptoms / Medical Notes</label>
            <textarea name="symptoms" id="symptoms" placeholder="Please provide brief detail of symptoms or reasons for consultation..." required></textarea>
        </div>

        <button type="submit" class="btn-submit">Confirm Appointment Request</button>
        
        <a href="patient-dashboard.jsp" class="back-link">← Cancel and Return to Dashboard</a>
    </form>
</div>

<script>
    // Prevent selecting historical dates past the present window timeline
    document.getElementById('appointmentDate').min = new Date().toISOString().split("T")[0];
</script>

</body>
</html>