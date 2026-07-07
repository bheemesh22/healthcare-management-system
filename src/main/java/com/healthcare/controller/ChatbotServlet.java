package com.healthcare.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/chatbot")
public class ChatbotServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // TODO: Paste your Gemini API key precisely here (starts with AIzaSy...)
    private static final String GEMINI_API_KEY = "AIzaSyA-jb-ZnvXcPCIDGx-Iv7A9cM0KeBED7Pw";
 // Change the version path from v1beta to v1
    private static final String API_URL = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=" + GEMINI_API_KEY;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // 1. Read incoming JSON message text from dashboard
        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String requestBody = sb.toString();
        String userMessage = "hi"; // Default fallback
        
        if (requestBody.contains("\"message\"")) {
            try {
                int startIndex = requestBody.indexOf("\"message\"") + 10;
                int endIndex = requestBody.indexOf("\"", startIndex);
                if (endIndex > startIndex) {
                    userMessage = requestBody.substring(startIndex, endIndex).trim();
                }
            } catch (Exception e) {
                System.out.println("⚠️ JSON parse warning, defaulting to standard hello string.");
            }
        }

        try {
            // 2. Format JSON payload for Gemini API structure
            String escapedMsg = userMessage.replace("\\", "\\\\").replace("\"", "\\\"");
            String jsonPayload = "{"
                    + "\"contents\": [{"
                    + "  \"parts\": [{"
                    + "    \"text\": \"" + escapedMsg + "\""
                    + "  }]"
                    + "}]"
                    + "}";

            // 3. Open connection to Google Generative Language endpoints
            URL url = new URL(API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setConnectTimeout(10000); 
            conn.setReadTimeout(10000);    
            conn.setDoOutput(true);

            // Transmit request bytes
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            
            // 4. Process Gemini JSON Response String
            if (responseCode == HttpURLConnection.HTTP_OK) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder apiResponse = new StringBuilder();
                    while ((line = br.readLine()) != null) {
                        apiResponse.append(line.trim());
                    }
                    
                    String rawText = apiResponse.toString();
                    String aiReply = "Hello! I am your health assistant. How can I help you today?";
                    
                    // Simple parsing logic to pull content from Gemini's response: candidate -> content -> parts -> text
                    if (rawText.contains("\"text\"")) {
                        int contentStart = rawText.indexOf("\"text\"") + 8;
                        int contentEnd = rawText.indexOf("\"", contentStart);
                        if (contentEnd > contentStart) {
                            aiReply = rawText.substring(contentStart, contentEnd)
                                               .replace("\\n", " ")
                                               .replace("\\\"", "\"");
                        }
                    }
                    
                    response.getWriter().write("{\"reply\": \"" + aiReply + "\"}");
                }
            } else {
                System.err.println("❌ Gemini API Error Code received: " + responseCode);
                response.getWriter().write("{\"reply\": \"Gemini service returned status code " + responseCode + ".\"}");
            }
        } catch (Exception e) {
            System.err.println("❌ Critical Connection Exception encountered during execution:");
            e.printStackTrace();
            response.getWriter().write("{\"reply\": \"AI gateway connection failed.\"}");
        }
    }
}