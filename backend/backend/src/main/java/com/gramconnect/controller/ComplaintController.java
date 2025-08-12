package com.gramconnect.controller;

import com.gramconnect.dto.ComplaintRequest;
import com.gramconnect.model.Complaint;
import com.gramconnect.service.ComplaintService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/complaints")
@CrossOrigin(origins = "*")
public class ComplaintController {

    @Autowired
    private ComplaintService complaintService;

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> createComplaint(@Valid @RequestBody ComplaintRequest request, 
                                           HttpServletRequest httpRequest) {
        try {
            String userId = (String) httpRequest.getAttribute("userId");
            Complaint complaint = complaintService.createComplaint(userId, request);
            return ResponseEntity.ok(complaint);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/user")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<List<Complaint>> getUserComplaints(HttpServletRequest httpRequest) {
        String userId = (String) httpRequest.getAttribute("userId");
        List<Complaint> complaints = complaintService.getUserComplaints(userId);
        return ResponseEntity.ok(complaints);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public ResponseEntity<?> getComplaint(@PathVariable String id, HttpServletRequest httpRequest) {
        Optional<Complaint> complaint = complaintService.getComplaintById(id);
        if (complaint.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        String userId = (String) httpRequest.getAttribute("userId");
        String userType = (String) httpRequest.getAttribute("userType");
        
        // Users can only see their own complaints
        if ("USER".equals(userType) && !complaint.get().getUserId().equals(userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        return ResponseEntity.ok(complaint.get());
    }

    @PostMapping("/{id}/reminder")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> sendReminder(@PathVariable String id, HttpServletRequest httpRequest) {
        try {
            String userId = (String) httpRequest.getAttribute("userId");
            Complaint complaint = complaintService.sendReminder(id, userId);
            return ResponseEntity.ok(complaint);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/{id}/feedback")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> addFeedback(@PathVariable String id, 
                                       @RequestBody Map<String, Object> request,
                                       HttpServletRequest httpRequest) {
        try {
            String userId = (String) httpRequest.getAttribute("userId");
            String feedback = (String) request.get("feedback");
            Integer rating = (Integer) request.get("rating");
            
            Complaint complaint = complaintService.addFeedback(id, userId, feedback, rating);
            return ResponseEntity.ok(complaint);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    // Admin endpoints
    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Complaint>> getAllComplaints() {
        List<Complaint> complaints = complaintService.getAllComplaints();
        return ResponseEntity.ok(complaints);
    }

    @GetMapping("/admin/status/{status}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Complaint>> getComplaintsByStatus(@PathVariable String status) {
        try {
            Complaint.Status complaintStatus = Complaint.Status.valueOf(status.toUpperCase());
            List<Complaint> complaints = complaintService.getComplaintsByStatus(complaintStatus);
            return ResponseEntity.ok(complaints);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/admin/village/{village}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Complaint>> getComplaintsByVillage(@PathVariable String village) {
        List<Complaint> complaints = complaintService.getComplaintsByVillage(village);
        return ResponseEntity.ok(complaints);
    }

    @PutMapping("/admin/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateComplaintStatus(@PathVariable String id, 
                                                 @RequestBody Map<String, String> request) {
        try {
            String status = request.get("status");
            String adminResponse = request.get("adminResponse");
            
            Complaint.Status complaintStatus = Complaint.Status.valueOf(status.toUpperCase());
            Complaint complaint = complaintService.updateComplaintStatus(id, complaintStatus, adminResponse);
            
            return ResponseEntity.ok(complaint);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/admin/statistics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalComplaints", complaintService.getComplaintCountByStatus(null));
        stats.put("pendingComplaints", complaintService.getComplaintCountByStatus(Complaint.Status.PENDING));
        stats.put("inProgressComplaints", complaintService.getComplaintCountByStatus(Complaint.Status.IN_PROGRESS));
        stats.put("resolvedComplaints", complaintService.getComplaintCountByStatus(Complaint.Status.RESOLVED));
        
        // Category-wise statistics
        Map<String, Long> categoryStats = new HashMap<>();
        for (Complaint.Category category : Complaint.Category.values()) {
            categoryStats.put(category.name(), complaintService.getComplaintCountByCategory(category));
        }
        stats.put("categoryStatistics", categoryStats);
        
        return ResponseEntity.ok(stats);
    }
}