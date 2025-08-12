package com.gramconnect.dto;

import com.gramconnect.model.Complaint;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class ComplaintRequest {
    @NotNull(message = "Category is required")
    private Complaint.Category category;
    
    @NotBlank(message = "Description is required")
    private String description;
    
    private String imageBase64;
    
    @NotNull(message = "Location is required")
    private LocationDto location;
    
    @NotBlank(message = "Village is required")
    private String village;
    
    private String ward;

    public static class LocationDto {
        private double latitude;
        private double longitude;
        private String address;

        // Getters and Setters
        public double getLatitude() { return latitude; }
        public void setLatitude(double latitude) { this.latitude = latitude; }

        public double getLongitude() { return longitude; }
        public void setLongitude(double longitude) { this.longitude = longitude; }

        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
    }

    // Getters and Setters
    public Complaint.Category getCategory() { return category; }
    public void setCategory(Complaint.Category category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageBase64() { return imageBase64; }
    public void setImageBase64(String imageBase64) { this.imageBase64 = imageBase64; }

    public LocationDto getLocation() { return location; }
    public void setLocation(LocationDto location) { this.location = location; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }
}