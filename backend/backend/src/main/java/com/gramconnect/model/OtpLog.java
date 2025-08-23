package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.index.Indexed;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

import java.time.LocalDateTime;

@Document(collection = "otpLogs")
public class OtpLog {
    @Id
    private String id;

    @Field("type")
    private Type type;

    @NotBlank(message = "Identifier is required")
    @Indexed
    private String identifier;

    @NotBlank(message = "OTP is required")
    @Pattern(regexp = "^\\d{6}$", message = "OTP must be 6 digits")
    private String otp;

    private int attempts = 0;
    private int resendCount = 0;

    @CreatedDate
    private LocalDateTime createdAt;

    private LocalDateTime expiresAt;
    private LocalDateTime blockedUntil;

    public enum Type {
        PHONE, EMAIL, AADHAAR
    }

    // Constructors
    public OtpLog() {}

    public OtpLog(Type type, String identifier, String otp, LocalDateTime expiresAt) {
        this.type = type;
        this.identifier = identifier;
        this.otp = otp;
        this.expiresAt = expiresAt;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Type getType() { return type; }
    public void setType(Type type) { this.type = type; }

    public String getIdentifier() { return identifier; }
    public void setIdentifier(String identifier) { this.identifier = identifier; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }

    public int getAttempts() { return attempts; }
    public void setAttempts(int attempts) { this.attempts = attempts; }

    public int getResendCount() { return resendCount; }
    public void setResendCount(int resendCount) { this.resendCount = resendCount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public LocalDateTime getBlockedUntil() { return blockedUntil; }
    public void setBlockedUntil(LocalDateTime blockedUntil) { this.blockedUntil = blockedUntil; }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }

    public boolean isBlocked() {
        return blockedUntil != null && LocalDateTime.now().isBefore(blockedUntil);
    }

    public void incrementAttempts() {
        this.attempts++;
    }

    public void incrementResendCount() {
        this.resendCount++;
    }
}