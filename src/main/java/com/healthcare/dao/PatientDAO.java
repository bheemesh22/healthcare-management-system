package com.healthcare.dao;

import com.healthcare.model.PatientProfile;

public interface PatientDAO {
    // Retrieve a profile using the foreign key user ID
    PatientProfile getProfileByUserId(int userId);
    
    // Save a new profile or update an existing one
    boolean saveOrUpdateProfile(PatientProfile profile);
}