package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;

import java.util.List;

@Document(collection = "location_data")
public class LocationData {
    @Id
    private String id;
    
    @Indexed
    private String state;
    
    @Indexed
    private String district;
    
    @Indexed
    private String panchayat;
    
    private List<String> wards;
    
    private boolean isActive = true;

    // Constructors
    public LocationData() {}

    public LocationData(String state, String district, String panchayat, List<String> wards) {
        this.state = state;
        this.district = district;
        this.panchayat = panchayat;
        this.wards = wards;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public List<String> getWards() { return wards; }
    public void setWards(List<String> wards) { this.wards = wards; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}