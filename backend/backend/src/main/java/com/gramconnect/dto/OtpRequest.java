package com.gramconnect.dto;

import com.gramconnect.model.OtpVerification;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class OtpRequest {
    private String email;
    private String phoneNumber;

    private String identifier; // Accepts "email" or "phoneNumber" from frontend

    @NotBlank(message = "OTP is required for verification")
    private String otp;

    @NotNull(message = "OTP type is required")
    private OtpVerification.OtpType type;

    // === Constructors ===
    public OtpRequest() {}

    public OtpRequest(String identifier, OtpVerification.OtpType type) {
        setIdentifier(identifier);
        this.type = type;
    }

    // === Setter for identifier that maps to email or phone ===
    public void setIdentifier(String identifier) {
        this.identifier = identifier;
        if (identifier != null) {
            if (identifier.contains("@")) {
                this.email = identifier;
            } else {
                this.phoneNumber = identifier;
            }
        }
    }

    // === Getters ===
    public String getIdentifier() {
        return identifier;
    }

    public String getEmail() {
        return email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getOtp() {
        return otp;
    }

    public OtpVerification.OtpType getType() {
        return type;
    }

    // === Setters ===
    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public void setOtp(String otp) {
        this.otp = otp;
    }

    public void setType(OtpVerification.OtpType type) {
        this.type = type;
    }
}
