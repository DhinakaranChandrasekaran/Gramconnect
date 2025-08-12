package com.gramconnect.controller;

import com.gramconnect.model.Complaint;
import com.gramconnect.model.GarbageSchedule;
import com.gramconnect.model.MissedPickup;
import com.gramconnect.service.ComplaintService;
import com.gramconnect.service.GarbageScheduleService;
import com.gramconnect.service.MissedPickupService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired
    private ComplaintService complaintService;

    @Autowired
    private GarbageScheduleService garbageScheduleService;

    @Autowired
    private MissedPickupService missedPickupService;

    // ===== DASHBOARD =====
    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard() {
        Map<String, Object> dashboard = new HashMap<>();
        
        // Complaint Statistics
        dashboard.put("totalComplaints", complaintService.getComplaintCountByStatus(null));
        dashboard.put("pendingComplaints", complaintService.getComplaintCountByStatus(Complaint.Status.PENDING));
        dashboard.put("inProgressComplaints", complaintService.getComplaintCountByStatus(Complaint.Status.IN_PROGRESS));
        dashboard.put("resolvedComplaints", complaintService.getComplaintCountByStatus(Complaint.Status.RESOLVED));
        
        // Missed Pickup Statistics
        dashboard.put("totalMissedPickups", missedPickupService.getMissedPickupCountByStatus(null));
        dashboard.put("pendingMissedPickups", missedPickupService.getMissedPickupCountByStatus(MissedPickup.Status.PENDING));
        dashboard.put("acknowledgedMissedPickups", missedPickupService.getMissedPickupCountByStatus(MissedPickup.Status.ACKNOWLEDGED));
        dashboard.put("resolvedMissedPickups", missedPickupService.getMissedPickupCountByStatus(MissedPickup.Status.RESOLVED));
        
        // Garbage Schedule Statistics
        dashboard.put("totalSchedules", garbageScheduleService.getAllSchedules().size());
        dashboard.put("activeSchedules", garbageScheduleService.getActiveSchedulesCount());
        
        // Recent data
        List<Complaint> recentComplaints = complaintService.getAllComplaints();
        dashboard.put("recentComplaints", recentComplaints.stream().limit(5).toList());
        
        List<MissedPickup> recentMissedPickups = missedPickupService.getAllMissedPickups();
        dashboard.put("recentMissedPickups", recentMissedPickups.stream().limit(5).toList());
        
        return ResponseEntity.ok(dashboard);
    }

    // ===== COMPLAINT MANAGEMENT =====
    @GetMapping("/complaints")
    public ResponseEntity<List<Complaint>> getAllComplaints() {
        List<Complaint> complaints = complaintService.getAllComplaints();
        return ResponseEntity.ok(complaints);
    }

    @GetMapping("/complaints/pending")
    public ResponseEntity<List<Complaint>> getPendingComplaints() {
        List<Complaint> complaints = complaintService.getComplaintsByStatus(Complaint.Status.PENDING);
        return ResponseEntity.ok(complaints);
    }

    @GetMapping("/complaints/village/{village}")
    public ResponseEntity<List<Complaint>> getComplaintsByVillage(@PathVariable String village) {
        List<Complaint> complaints = complaintService.getComplaintsByVillage(village);
        return ResponseEntity.ok(complaints);
    }

    @PutMapping("/complaints/{id}/status")
    public ResponseEntity<?> updateComplaintStatus(@PathVariable String id, 
                                                 @RequestBody Map<String, String> request) {
        try {
            String status = request.get("status");
            String adminResponse = request.get("adminResponse");
            
            Complaint.Status complaintStatus = Complaint.Status.valueOf(status.toUpperCase());
            Complaint complaint = complaintService.updateComplaintStatus(id, complaintStatus, adminResponse);
            
            return ResponseEntity.ok(Map.of("success", true, "data", complaint));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // ===== GARBAGE SCHEDULE MANAGEMENT =====
    @GetMapping("/garbage-schedules")
    public ResponseEntity<List<GarbageSchedule>> getAllGarbageSchedules() {
        List<GarbageSchedule> schedules = garbageScheduleService.getAllSchedules();
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/garbage-schedules/village/{village}")
    public ResponseEntity<List<GarbageSchedule>> getSchedulesByVillage(@PathVariable String village) {
        List<GarbageSchedule> schedules = garbageScheduleService.getSchedulesByPanchayat(village);
        return ResponseEntity.ok(schedules);
    }

    @PostMapping("/garbage-schedules")
    public ResponseEntity<?> createGarbageSchedule(@RequestBody GarbageSchedule schedule) {
        try {
            GarbageSchedule created = garbageScheduleService.createSchedule(schedule);
            return ResponseEntity.ok(Map.of("success", true, "data", created));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PutMapping("/garbage-schedules/{id}")
    public ResponseEntity<?> updateGarbageSchedule(@PathVariable String id, @RequestBody GarbageSchedule schedule) {
        try {
            GarbageSchedule updated = garbageScheduleService.updateSchedule(id, schedule);
            return ResponseEntity.ok(Map.of("success", true, "data", updated));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @DeleteMapping("/garbage-schedules/{id}")
    public ResponseEntity<?> deleteGarbageSchedule(@PathVariable String id) {
        try {
            garbageScheduleService.deleteSchedule(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Schedule deleted successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // ===== MISSED PICKUP MANAGEMENT =====
    @GetMapping("/missed-pickups")
    public ResponseEntity<List<MissedPickup>> getAllMissedPickups() {
        List<MissedPickup> missedPickups = missedPickupService.getAllMissedPickups();
        return ResponseEntity.ok(missedPickups);
    }

    @GetMapping("/missed-pickups/pending")
    public ResponseEntity<List<MissedPickup>> getPendingMissedPickups() {
        List<MissedPickup> missedPickups = missedPickupService.getMissedPickupsByStatus(MissedPickup.Status.PENDING);
        return ResponseEntity.ok(missedPickups);
    }

    @GetMapping("/missed-pickups/village/{village}")
    public ResponseEntity<List<MissedPickup>> getMissedPickupsByVillage(@PathVariable String village) {
        List<MissedPickup> missedPickups = missedPickupService.getMissedPickupsByVillage(village);
        return ResponseEntity.ok(missedPickups);
    }

    @PutMapping("/missed-pickups/{id}/status")
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

    // ===== STATISTICS ENDPOINTS =====
    @GetMapping("/statistics/complaints")
    public ResponseEntity<Map<String, Object>> getComplaintStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", complaintService.getComplaintCountByStatus(null));
        stats.put("pending", complaintService.getComplaintCountByStatus(Complaint.Status.PENDING));
        stats.put("inProgress", complaintService.getComplaintCountByStatus(Complaint.Status.IN_PROGRESS));
        stats.put("resolved", complaintService.getComplaintCountByStatus(Complaint.Status.RESOLVED));
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/statistics/missed-pickups")
    public ResponseEntity<Map<String, Object>> getMissedPickupStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", missedPickupService.getMissedPickupCountByStatus(null));
        stats.put("pending", missedPickupService.getMissedPickupCountByStatus(MissedPickup.Status.PENDING));
        stats.put("acknowledged", missedPickupService.getMissedPickupCountByStatus(MissedPickup.Status.ACKNOWLEDGED));
        stats.put("resolved", missedPickupService.getMissedPickupCountByStatus(MissedPickup.Status.RESOLVED));
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/statistics/garbage-schedules")
    public ResponseEntity<Map<String, Object>> getGarbageScheduleStatistics() {
        Map<String, Object> stats = new HashMap<>();
        List<GarbageSchedule> allSchedules = garbageScheduleService.getAllSchedules();
        stats.put("total", allSchedules.size());
        stats.put("active", allSchedules.stream().mapToLong(s -> s.isActive() ? 1 : 0).sum());
        stats.put("inactive", allSchedules.stream().mapToLong(s -> !s.isActive() ? 1 : 0).sum());
        return ResponseEntity.ok(stats);
    }
}