package com.gramconnect.dto.complaint;

import com.gramconnect.model.Complaint;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class ComplaintRequest {
    @NotNull(message = "Category is required")
    private Complaint.Category category;

   private String title;

    @NotBlank(message = "Description is required")
    @Size(min = 10, max = 500, message = "Description must be between 10 and 500 characters")
    private String description;

    @NotBlank(message = "District is required")
    private String district;

    @NotBlank(message = "Panchayat is required")
    private String panchayat;

    @NotBlank(message = "Village is required")
    private String village;

    @NotBlank(message = "Ward is required")
    private String ward;

    private double lat;
    private double lng;

    // Constructors
    public ComplaintRequest() {}

   public ComplaintRequest(Complaint.Category category, String title, String description, String district, 
                           String panchayat, String village, String ward) {
        this.category = category;
       this.title = title;
        this.description = description;
        this.district = district;
        this.panchayat = panchayat;
        this.village = village;
        this.ward = ward;
    }

    // Getters and Setters
    public Complaint.Category getCategory() { return category; }
    public void setCategory(Complaint.Category category) { this.category = category; }

   public String getTitle() { return title; }
   public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public double getLat() { return lat; }
    public void setLat(double lat) { this.lat = lat; }

    public double getLng() { return lng; }
    public void setLng(double lng) { this.lng = lng; }
}