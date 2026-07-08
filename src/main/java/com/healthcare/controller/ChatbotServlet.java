package com.healthcare.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/chatbot")
public class ChatbotServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Session Guard Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // 2. Read raw text input stream payload from request body
        StringBuilder jsonBuffer = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
        }

        String rawInput = jsonBuffer.toString().toLowerCase();
        
        // Extract plain message content if sent as clean text or simple JSON body
        String userMessage = "";
        if (rawInput.contains("\"message\"")) {
            // Quick extraction helper to isolate the JSON string property values
            userMessage = rawInput.split("\"message\"")[1].replaceAll("[^a-zA-Z0-9\\s]", "").trim();
        } else {
            userMessage = rawInput.trim();
        }

        // 3. Rule-Based Symptom Diagnostics Rule Processing Matrix
        String botReply;
        if (userMessage.contains("fever") || userMessage.contains("temperature") || userMessage.contains("chills")) {
            botReply = "🌡️ *Symptom Note:* High temperatures can indicate an active infection response. Stay well hydrated, monitor your metrics regularly, and schedule a consultation with a General Physician if conditions persist past 48 hours.";
        } else if (userMessage.contains("cough") || userMessage.contains("cold") || userMessage.contains("throat")) {
            botReply = "🫁 *Symptom Note:* Respiratory congestion can be viral or seasonal. Consider warm fluids or throat lozenges. If you experience shortness of breath, please book an immediate window with a Pulmonologist Specialist.";
        } else if (userMessage.contains("headache") || userMessage.contains("migraine") || userMessage.contains("dizzy")) {
            botReply = "🧠 *Symptom Note:* Headaches can stems from muscle strain, low hydration, or sleep variations. Rest in a dark space and track your stress levels. Persistent chronic migraines should be evaluated by a Neurologist.";
        } else if (userMessage.contains("stomach") || userMessage.contains("pain") || userMessage.contains("cramp")) {
            botReply = "🤢 *Symptom Note:* Abdominal distress could be related to digestive acidity, food triggers, or inflammation. Avoid heavy meals. If the discomfort is severe or sharp, consult a Gastroenterologist promptly.";
        } else if (userMessage.contains("hello") || userMessage.contains("hi") || userMessage.contains("hey")) {
            botReply = "👋 Hello! I am your AI Health Assistant. Tell me about any current physical symptoms or discomforts you are tracking, and I can give you quick guidelines and specialist recommendations!";
        } else {
            botReply = "📋 *System Note:* I've acknowledged your query. For specialized diagnostics, ensure your symptoms are completely described inside your appointment booking summary details so our medical professionals can review them closely.";
        }

        // 4. Send back a clean, formal JSON structural response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Formatting explicit JSON string payload object block securely
        String jsonResponse = "{\"reply\": \"" + botReply + "\"}";
        
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonResponse);
            out.flush();
        }
    }
}