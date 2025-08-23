package com.gramconnect.service;

import com.gramconnect.dto.user.UserProfileRequest;
import com.gramconnect.dto.user.UserResponse;
import com.gramconnect.model.User;
import com.gramconnect.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserResponse getCurrentUser(String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        return new UserResponse(user);
    }

    public UserResponse updateProfile(String userId, UserProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        // Update profile fields
        user.setDistrict(request.getDistrict());
        user.setPanchayat(request.getPanchayat());
        user.setVillage(request.getVillage());
        user.setWard(request.getWard());
        user.setHomeAddress(request.getHomeAddress());
        
        if (request.getAadhaarNumber() != null) {
            user.setAadhaarNumber(request.getAadhaarNumber());
        }

        // Mark profile as completed
        user.setProfileCompleted(true);

        user = userRepository.save(user);
        return new UserResponse(user);
    }
}