package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.FieldType;

import java.time.LocalDateTime;

@Document(collection = "otp_verifications")
public class OtpVerification {
    @Id
    private String id;

    @Indexed
    private String identifier; // email or phone number

    private String otp;

    @Field(targetType = FieldType.STRING) // ✅ Force enum to be stored as string
    private OtpType type;

    private LocalDateTime createdAt;

    @Indexed(expireAfterSeconds = 300) // 5 minutes TTL
    private LocalDateTime expiresAt;

    private int attempts = 0;

    private boolean verified = false;

    public enum OtpType {
        EMAIL_REGISTRATION,
        EMAIL_LOGIN,
        PHONE_REGISTRATION,
        PHONE_LOGIN,
        PASSWORD_RESET,
        AADHAAR_VERIFICATION // ✅ This is the missing enum
    }

    // Constructors
    public OtpVerification() {
        this.createdAt = LocalDateTime.now();
        this.expiresAt = this.createdAt.plusMinutes(5);
    }

    public OtpVerification(String identifier, String otp, OtpType type) {
        this();
        this.identifier = identifier;
        this.otp = otp;
        this.type = type;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getIdentifier() { return identifier; }
    public void setIdentifier(String identifier) { this.identifier = identifier; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }

    public OtpType getType() { return type; }
    public void setType(OtpType type) { this.type = type; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public int getAttempts() { return attempts; }
    public void setAttempts(int attempts) { this.attempts = attempts; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }
}
