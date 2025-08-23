package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

@Document(collection = "complaints")
public class Complaint {
    @Id
    private String id;

    @NotBlank(message = "User ID is required")
    private String userId;

    @NotNull(message = "Category is required")
    private Category category;

  
   private String title;
    @NotBlank(message = "Description is required")
    @Size(min = 10, max = 500, message = "Description must be between 10 and 500 characters")
    private String description;

    private String imageUrl;

    @NotBlank(message = "District is required")
    private String district;

    @NotBlank(message = "Panchayat is required")
    private String panchayat;

    @NotBlank(message = "Village is required")
    private String village;

    @NotBlank(message = "Ward is required")
    private String ward;

    @Field("location")
    private Location location;

    @Field("status")
    private Status status = Status.PENDING;

    private boolean reminderSent = false;

    @Field("feedback")
    private Feedback feedback;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    // Inner Classes
    public static class Location {
        private double lat;
        private double lng;

        public Location() {}

        public Location(double lat, double lng) {
            this.lat = lat;
            this.lng = lng;
        }

        // Getters and Setters
        public double getLat() { return lat; }
        public void setLat(double lat) { this.lat = lat; }
        public double getLng() { return lng; }
        public void setLng(double lng) { this.lng = lng; }
    }

    public static class Feedback {
        private Rating rating;
        private String note;
        private LocalDateTime at;

        public Feedback() {}

        public Feedback(Rating rating, String note) {
            this.rating = rating;
            this.note = note;
            this.at = LocalDateTime.now();
        }

        // Getters and Setters
        public Rating getRating() { return rating; }
        public void setRating(Rating rating) { this.rating = rating; }
        public String getNote() { return note; }
        public void setNote(String note) { this.note = note; }
        public LocalDateTime getAt() { return at; }
        public void setAt(LocalDateTime at) { this.at = at; }

        public enum Rating {
            SATISFIED, NOT_SATISFIED
        }
    }

    public enum Category {
        GARBAGE, WATER, ELECTRICITY, DRAINAGE, ROAD_DAMAGE, HEALTH, TRANSPORT
    }

    public enum Status {
        PENDING, IN_PROGRESS, RESOLVED
    }

    // Constructors
    public Complaint() {}

    public Complaint(String userId, Category category, String description, 
                    String district, String panchayat, String village, String ward) {
        this.userId = userId;
        this.category = category;
        this.description = description;
        this.district = district;
        this.panchayat = panchayat;
        this.village = village;
        this.ward = ward;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

   public String getTitle() { return title; }
   public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public Location getLocation() { return location; }
    public void setLocation(Location location) { this.location = location; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public boolean isReminderSent() { return reminderSent; }
    public void setReminderSent(boolean reminderSent) { this.reminderSent = reminderSent; }

    public Feedback getFeedback() { return feedback; }
    public void setFeedback(Feedback feedback) { this.feedback = feedback; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}