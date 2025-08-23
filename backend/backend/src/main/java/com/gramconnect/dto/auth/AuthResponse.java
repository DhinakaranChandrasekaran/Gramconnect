package com.gramconnect.dto.auth;

import com.gramconnect.model.User;

public class AuthResponse {
    private String token;
    private String userId;
    private User.Role role;
    private boolean profileCompleted;
    private String message;

    // For OTP responses
    private String otp; // Only in dev mode

    // Constructors
    public AuthResponse() {}

    public AuthResponse(String token, String userId, User.Role role, boolean profileCompleted) {
        this.token = token;
        this.userId = userId;
        this.role = role;
        this.profileCompleted = profileCompleted;
    }

    public AuthResponse(String message) {
        this.message = message;
    }

    // Getters and Setters
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public User.Role getRole() { return role; }
    public void setRole(User.Role role) { this.role = role; }

    public boolean isProfileCompleted() { return profileCompleted; }
    public void setProfileCompleted(boolean profileCompleted) { this.profileCompleted = profileCompleted; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }
}