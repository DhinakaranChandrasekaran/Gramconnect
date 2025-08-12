package com.gramconnect.controller;

import com.gramconnect.service.LocationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/locations")
@CrossOrigin(origins = "*")
public class LocationController {

    @Autowired
    private LocationService locationService;

    @GetMapping("/districts")
    public ResponseEntity<List<String>> getDistricts(@RequestParam(defaultValue = "Tamil Nadu") String state) {
        List<String> districts = locationService.getDistricts(state);
        return ResponseEntity.ok(districts);
    }

    @GetMapping("/panchayats")
    public ResponseEntity<List<String>> getPanchayats(@RequestParam String district) {
        List<String> panchayats = locationService.getPanchayats(district);
        return ResponseEntity.ok(panchayats);
    }

    @GetMapping("/wards")
    public ResponseEntity<List<String>> getWards(@RequestParam String district, @RequestParam String panchayat) {
        List<String> wards = locationService.getWards(district, panchayat);
        return ResponseEntity.ok(wards);
    }
}