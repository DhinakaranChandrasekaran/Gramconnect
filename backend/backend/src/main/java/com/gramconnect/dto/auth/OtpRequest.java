package com.gramconnect.dto.auth;

import com.gramconnect.model.OtpLog;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class OtpRequest {
    @NotBlank(message = "Identifier is required")
    private String identifier;

    @NotNull(message = "Type is required")
    private OtpLog.Type type;

    private String otp; // For verification requests

    // Constructors
    public OtpRequest() {}

    public OtpRequest(String identifier, OtpLog.Type type) {
        this.identifier = identifier;
        this.type = type;
    }

    public OtpRequest(String identifier, OtpLog.Type type, String otp) {
        this.identifier = identifier;
        this.type = type;
        this.otp = otp;
    }

    // Getters and Setters
    public String getIdentifier() { return identifier; }
    public void setIdentifier(String identifier) { this.identifier = identifier; }

    public OtpLog.Type getType() { return type; }
    public void setType(OtpLog.Type type) { this.type = type; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }
}