package com.gramconnect.dto.auth;

import jakarta.validation.constraints.NotBlank;

public class GoogleSignInRequest {
    @NotBlank(message = "ID token is required")
    private String idToken;

    // Constructors
    public GoogleSignInRequest() {}

    public GoogleSignInRequest(String idToken) {
        this.idToken = idToken;
    }

    // Getters and Setters
    public String getIdToken() { return idToken; }
    public void setIdToken(String idToken) { this.idToken = idToken; }
}