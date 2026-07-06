package com.healthcare.dao;

import com.healthcare.model.User;

public interface UserDAO {
    /**
     * Inserts a new user record into the users table during registration.
     * @param user The user object containing registration details.
     * @return true if registration is successful, false otherwise.
     */
    boolean registerUser(User user);

    /**
     * Validates credentials against the users table for authentication.
     * @param username The inputted username or email.
     * @param password The inputted plain text password.
     * @return A fully populated User object if found, or null if validation fails.
     */
    User loginUser(String username, String password);
}