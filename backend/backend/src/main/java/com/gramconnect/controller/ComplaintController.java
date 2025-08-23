package com.gramconnect.controller;

import com.gramconnect.dto.complaint.ComplaintRequest;
import com.gramconnect.dto.complaint.ComplaintResponse;
import com.gramconnect.model.Complaint;
import com.gramconnect.service.ComplaintService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/complaints")
@Tag(name = "Complaints", description = "Complaint management operations")
@CrossOrigin(origins = "*")
@SecurityRequirement(name = "bearerAuth")
public class ComplaintController {
    private final ComplaintService complaintService;

    public ComplaintController(ComplaintService complaintService) {
        this.complaintService = complaintService;
    }

    @PostMapping
    @Operation(summary = "Create new complaint")
    public ResponseEntity<ComplaintResponse> createComplaint(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody ComplaintRequest request) {
        return ResponseEntity.ok(complaintService.createComplaint(userId, request));
    }

    @GetMapping("/user")
    @Operation(summary = "Get current user's complaints")
    public ResponseEntity<List<ComplaintResponse>> getUserComplaints(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(complaintService.getUserComplaints(userId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get complaint details")
    public ResponseEntity<ComplaintResponse> getComplaintDetails(
            @PathVariable String id,
            @AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(complaintService.getComplaintDetails(id, userId));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Update complaint status (admin only)")
    public ResponseEntity<ComplaintResponse> updateStatus(
            @PathVariable String id,
            @RequestBody Map<String, String> statusRequest) {
        Complaint.Status status = Complaint.Status.valueOf(statusRequest.get("status"));
        return ResponseEntity.ok(complaintService.updateStatus(id, status));
    }

    @PostMapping("/{id}/feedback")
    @Operation(summary = "Submit feedback for resolved complaint")
    public ResponseEntity<ComplaintResponse> submitFeedback(
            @PathVariable String id,
            @AuthenticationPrincipal String userId,
            @RequestParam Complaint.Feedback.Rating rating,
            @RequestParam(required = false) String note) {
        return ResponseEntity.ok(complaintService.submitFeedback(id, userId, rating, note));
    }

    @GetMapping("/{id}/can-remind")
    @Operation(summary = "Check if reminder can be sent")
    public ResponseEntity<Map<String, Boolean>> canRemind(
            @PathVariable String id,
            @AuthenticationPrincipal String userId) {
        boolean canRemind = complaintService.canSendReminder(id, userId);
        return ResponseEntity.ok(Map.of("canRemind", canRemind));
    }

    @PostMapping("/{id}/reminder")
    @Operation(summary = "Send complaint reminder")
    public ResponseEntity<String> sendReminder(
            @PathVariable String id,
            @AuthenticationPrincipal String userId) {
        complaintService.sendReminder(id, userId);
        return ResponseEntity.ok("Reminder sent successfully");
    }
}