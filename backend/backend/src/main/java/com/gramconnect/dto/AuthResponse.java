package com.gramconnect.dto;

import java.time.LocalDateTime;

public class AuthResponse {
    private String token;
    private String userId;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String district;
    private String panchayat;
    private String ward;
    private String homeAddress;
    private String aadhaarNumber;
    private boolean aadhaarVerified;
    private String userType; // USER or ADMIN
    private LocalDateTime expiresAt;
    private boolean requiresOtpVerification;
    private String message;
    private String otpForTesting; // Only for testing purposes

    // Constructors
    public AuthResponse() {}

    public AuthResponse(String token, String userId, String fullName, String userType) {
        this.token = token;
        this.userId = userId;
        this.fullName = fullName;
        this.userType = userType;
    }

    // Getters and Setters
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public String getHomeAddress() { return homeAddress; }
    public void setHomeAddress(String homeAddress) { this.homeAddress = homeAddress; }

    public String getAadhaarNumber() { return aadhaarNumber; }
    public void setAadhaarNumber(String aadhaarNumber) { this.aadhaarNumber = aadhaarNumber; }

    public boolean isAadhaarVerified() { return aadhaarVerified; }
    public void setAadhaarVerified(boolean aadhaarVerified) { this.aadhaarVerified = aadhaarVerified; }

    public String getUserType() { return userType; }
    public void setUserType(String userType) { this.userType = userType; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public boolean isRequiresOtpVerification() { return requiresOtpVerification; }
    public void setRequiresOtpVerification(boolean requiresOtpVerification) { this.requiresOtpVerification = requiresOtpVerification; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public String getOtpForTesting() { return otpForTesting; }
    public void setOtpForTesting(String otpForTesting) { this.otpForTesting = otpForTesting; }
}