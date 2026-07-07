package com.healthcare.dao;

import com.healthcare.model.User;

public interface UserDAO {
    boolean isUserExists(String username, String email);
    boolean registerUser(User user);
    User validateUser(String username, String password);
}