package com.gramconnect.dto.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class UserProfileRequest {
    @NotBlank(message = "District is required")
    private String district;

    @NotBlank(message = "Panchayat is required")
    private String panchayat;

    @NotBlank(message = "Village is required")
    private String village;

    @NotBlank(message = "Ward is required")
    private String ward;

    @NotBlank(message = "Home address is required")
    @Size(min = 5, max = 200, message = "Home address must be between 5 and 200 characters")
    private String homeAddress;

    @Pattern(regexp = "^\\d{12}$", message = "Aadhaar number must be 12 digits")
    private String aadhaarNumber;

    // Constructors
    public UserProfileRequest() {}

    public UserProfileRequest(String district, String panchayat, String village, String ward, String homeAddress) {
        this.district = district;
        this.panchayat = panchayat;
        this.village = village;
        this.ward = ward;
        this.homeAddress = homeAddress;
    }

    // Getters and Setters
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public String getHomeAddress() { return homeAddress; }
    public void setHomeAddress(String homeAddress) { this.homeAddress = homeAddress; }

    public String getAadhaarNumber() { return aadhaarNumber; }
    public void setAadhaarNumber(String aadhaarNumber) { this.aadhaarNumber = aadhaarNumber; }
}