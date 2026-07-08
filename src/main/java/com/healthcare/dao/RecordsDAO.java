package com.healthcare.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.healthcare.model.MedicalRecord;
import com.healthcare.util.DBConnection;

public class RecordsDAO {

    public boolean addMedicalRecord(int userId, String reportName, String filePath) {
        String sql = "INSERT INTO medical_records (user_id, report_name, file_path) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setString(2, reportName.trim());
            ps.setString(3, filePath);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<MedicalRecord> getRecordsByUserId(int userId) {
        List<MedicalRecord> list = new ArrayList<>();
        String sql = "SELECT * FROM medical_records WHERE user_id = ? ORDER BY uploaded_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MedicalRecord record = new MedicalRecord();
                    record.setRecordId(rs.getInt("record_id"));
                    record.setUserId(rs.getInt("user_id"));
                    record.setReportName(rs.getString("report_name"));
                    record.setFilePath(rs.getString("file_path"));
                    record.setUploadedAt(rs.getTimestamp("uploaded_at"));
                    list.add(record);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}