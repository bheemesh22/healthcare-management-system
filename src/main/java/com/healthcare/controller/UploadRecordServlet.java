package com.healthcare.controller;

import java.io.File;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import com.healthcare.model.User;
import com.healthcare.dao.RecordsDAO;

@WebServlet("/uploadRecord")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB cache allocation
    maxFileSize = 1024 * 1024 * 10,       // 10MB maximum file cap
    maxRequestSize = 1024 * 1024 * 50     // 50MB overall payload restriction
)
public class UploadRecordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final RecordsDAO recordsDAO = new RecordsDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        
        // Define absolute path destination inside deployment metadata directory structure
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir(); // Creates the directory if it doesn't exist yet
        }

        try {
            String reportName = request.getParameter("reportName");
            Part filePart = request.getPart("documentFile"); // Matches form input name
            
            // Extract file name safely
            String fileName = System.currentTimeMillis() + "_" + getFileName(filePart);
            String fullSavePath = uploadPath + File.separator + fileName;
            
            // Write the file raw binary directly onto server storage layout disk
            filePart.write(fullSavePath);
            
            // Compute structural context reference path to write into database mapping
            String relativeDatabasePath = "uploads/" + fileName;
            
            boolean success = recordsDAO.addMedicalRecord(currentUser.getUserId(), reportName, relativeDatabasePath);
            
            if (success) {
                response.sendRedirect("medical-records.jsp?success=Document archived perfectly!");
            } else {
                response.sendRedirect("medical-records.jsp?error=Database tracking mapping registration failed.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("medical-records.jsp?error=Internal execution compilation exception processing multipart files.");
        }
    }

    // Helper method to extract original submitted file extension naming strings
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "unknown_report.pdf";
    }
}