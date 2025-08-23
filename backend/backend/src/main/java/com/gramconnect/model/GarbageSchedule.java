package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;

import java.time.LocalDateTime;
import java.util.List;

@Document(collection = "garbageSchedules")
public class GarbageSchedule {
    @Id
    private String id;

    @NotBlank(message = "District is required")
    private String district;

    @NotBlank(message = "Panchayat is required")
    private String panchayat;

    @NotBlank(message = "Village is required")
    private String village;

    @NotBlank(message = "Ward is required")
    private String ward;

    @NotEmpty(message = "At least one day is required")
    private List<DayOfWeek> days;

    @NotBlank(message = "Time is required")
    @Pattern(regexp = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$", message = "Time must be in HH:mm format")
    private String time;

    @Field("areaPolygon")
    private String areaPolygon;

    @NotBlank(message = "Created by admin ID is required")
    private String createdByAdminId;

    @CreatedDate
    private LocalDateTime createdAt;

    public enum DayOfWeek {
        MON, TUE, WED, THU, FRI, SAT, SUN
    }

    // Constructors
    public GarbageSchedule() {}

    public GarbageSchedule(String district, String panchayat, String village, String ward,
                          List<DayOfWeek> days, String time, String createdByAdminId) {
        this.district = district;
        this.panchayat = panchayat;
        this.village = village;
        this.ward = ward;
        this.days = days;
        this.time = time;
        this.createdByAdminId = createdByAdminId;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public List<DayOfWeek> getDays() { return days; }
    public void setDays(List<DayOfWeek> days) { this.days = days; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }

    public String getAreaPolygon() { return areaPolygon; }
    public void setAreaPolygon(String areaPolygon) { this.areaPolygon = areaPolygon; }

    public String getCreatedByAdminId() { return createdByAdminId; }
    public void setCreatedByAdminId(String createdByAdminId) { this.createdByAdminId = createdByAdminId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}