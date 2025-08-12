package com.gramconnect.controller;

import com.gramconnect.model.MissedPickup;
import com.gramconnect.service.MissedPickupService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/missed-pickups")
@CrossOrigin(origins = "*")
public class MissedPickupController {

    @Autowired
    private MissedPickupService missedPickupService;

    // User reports missed pickup - matches Flutter frontend
    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> reportMissedPickup(@RequestBody Map<String, Object> request,
                                                HttpServletRequest httpRequest) {
        try {
            String userId = (String) httpRequest.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).body(Map.of("success", false, "message", "Unauthorized"));
            }

            String reason = (String) request.get("reason");
            String description = (String) request.get("description");
            String dateStr = (String) request.get("scheduledDate");

            if (reason == null || reason.isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Reason is required"));
            }

            // Parse scheduled date
            LocalDateTime scheduledDate;
            if (dateStr != null && !dateStr.isBlank()) {
                try {
                    DateTimeFormatter formatter = DateTimeFormatter.ISO_DATE_TIME;
                    scheduledDate = LocalDateTime.parse(dateStr, formatter);
                } catch (DateTimeParseException e) {
                    return ResponseEntity.badRequest().body(Map.of(
                            "success", false,
                            "message", "Invalid date format. Use ISO format (YYYY-MM-DDTHH:MM:SS)"
                    ));
                }
            } else {
                scheduledDate = LocalDateTime.now();
            }

            // Call service - it will get user details automatically
            MissedPickup missedPickup = missedPickupService.reportMissedPickup(
                    userId, scheduledDate, reason, description != null ? description : ""
            );

            return ResponseEntity.ok(Map.of("success", true, "data", missedPickup));

        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Invalid request data"));
        }
    }

    // User views their own missed pickups
    @GetMapping("/user")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> getUserMissedPickups(HttpServletRequest httpRequest) {
        String userId = (String) httpRequest.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Unauthorized"));
        }
        List<MissedPickup> missedPickups = missedPickupService.getUserMissedPickups(userId);
        return ResponseEntity.ok(Map.of("success", true, "data", missedPickups));
    }

    // Admin views all missed pickups
    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getAllMissedPickups() {
        return ResponseEntity.ok(Map.of("success", true, "data", missedPickupService.getAllMissedPickups()));
    }

    // Admin views missed pickups by village
    @GetMapping("/admin/village/{village}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getMissedPickupsByVillage(@PathVariable String village) {
        return ResponseEntity.ok(Map.of("success", true, "data", missedPickupService.getMissedPickupsByVillage(village)));
    }

    // Admin updates status and adds response
    @PutMapping("/admin/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateMissedPickupStatus(@PathVariable String id,
                                                      @RequestBody Map<String, String> request) {
        try {
            String status = request.get("status");
            String adminResponse = request.get("adminResponse");

            if (status == null || status.isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Status is required"));
            }

            MissedPickup.Status pickupStatus;
            try {
                pickupStatus = MissedPickup.Status.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Invalid status value"));
            }

            MissedPickup missedPickup = missedPickupService.updateMissedPickupStatus(
                    id, pickupStatus, adminResponse
            );

            return ResponseEntity.ok(Map.of("success", true, "data", missedPickup));

        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}