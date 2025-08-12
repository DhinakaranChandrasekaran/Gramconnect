package com.gramconnect.service;

import com.gramconnect.model.User;
import com.gramconnect.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public User getUserById(String userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    public User updateUserProfile(String userId, Map<String, Object> updates) {
        User user = getUserById(userId);

        // Safely update each field if provided
        updates.forEach((key, value) -> {
            switch (key) {
                case "fullName" -> user.setFullName((String) value);
                case "email" -> user.setEmail((String) value);
                case "phoneNumber" -> user.setPhoneNumber((String) value);
                case "district" -> user.setDistrict((String) value);
                case "panchayat" -> user.setPanchayat((String) value);
                case "ward" -> user.setWard((String) value);
                case "homeAddress" -> user.setHomeAddress((String) value);
                case "aadhaarNumber" -> user.setAadhaarNumber((String) value);
                case "aadhaarVerified" -> user.setAadhaarVerified((Boolean) value);
            }
        });

        return userRepository.save(user);
    }

    public User completeUserProfile(String userId, Map<String, Object> profileData) {
        User user = updateUserProfile(userId, profileData);
        user.setProfileCompleted(true);
        return userRepository.save(user);
    }
}
