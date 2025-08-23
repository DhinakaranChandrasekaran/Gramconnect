package com.gramconnect.controller;

import com.gramconnect.model.MissedPickup;
import com.gramconnect.service.MissedPickupService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/missed-pickups")
@Tag(name = "Missed Pickups", description = "Missed pickup reporting operations")
@CrossOrigin(origins = "*")
@SecurityRequirement(name = "bearerAuth")
public class MissedPickupController {
    private final MissedPickupService missedPickupService;

    public MissedPickupController(MissedPickupService missedPickupService) {
        this.missedPickupService = missedPickupService;
    }

    @PostMapping
    @Operation(summary = "Report missed pickup")
    public ResponseEntity<MissedPickup> reportMissedPickup(
            @AuthenticationPrincipal String userId,
            @RequestBody Map<String, String> request) {
        return ResponseEntity.ok(missedPickupService.reportMissedPickup(
            userId,
            request.get("scheduleId"),
            request.get("village"),
            request.get("note")
        ));
    }

    @GetMapping("/my")
    @Operation(summary = "Get current user's missed pickup reports")
    public ResponseEntity<List<MissedPickup>> getMyMissedPickups(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(missedPickupService.getUserMissedPickups(userId));
    }

    @GetMapping
    @Operation(summary = "Get all missed pickups (admin only)")
    public ResponseEntity<List<MissedPickup>> getAllMissedPickups(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String village) {
        
        if (status != null) {
            MissedPickup.Status statusEnum = MissedPickup.Status.valueOf(status.toUpperCase());
            return ResponseEntity.ok(missedPickupService.getMissedPickupsByStatus(statusEnum));
        } else if (village != null) {
            return ResponseEntity.ok(missedPickupService.getMissedPickupsByVillage(village));
        } else {
            return ResponseEntity.ok(missedPickupService.getAllMissedPickups());
        }
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Update missed pickup status (admin only)")
    public ResponseEntity<MissedPickup> updateStatus(
            @PathVariable String id,
            @AuthenticationPrincipal String adminId,
            @RequestBody Map<String, String> statusRequest) {
        MissedPickup.Status status = MissedPickup.Status.valueOf(statusRequest.get("status").toUpperCase());
        return ResponseEntity.ok(missedPickupService.updateStatus(id, status, adminId));
    }
}