package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Document(collection = "garbage_schedules")
public class GarbageSchedule {

    @Id
    private String id;

    private String district;
    private String panchayat;
    private String ward;
    private String area;
    private List<String> collectionDays;
    
    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime pickupTime;
    
    private String description;
    private boolean isActive = true;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    // Constructors
    public GarbageSchedule() {}

    public GarbageSchedule(String district, String panchayat, String ward, String area, 
                          List<String> collectionDays, LocalTime pickupTime) {
        this.district = district;
        this.panchayat = panchayat;
        this.ward = ward;
        this.area = area;
        this.collectionDays = collectionDays;
        this.pickupTime = pickupTime;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }

    public List<String> getCollectionDays() { return collectionDays; }
    public void setCollectionDays(List<String> collectionDays) { this.collectionDays = collectionDays; }

    public LocalTime getPickupTime() { return pickupTime; }
    public void setPickupTime(LocalTime pickupTime) { this.pickupTime = pickupTime; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}