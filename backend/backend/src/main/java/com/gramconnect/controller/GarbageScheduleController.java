package com.gramconnect.controller;

import com.gramconnect.model.GarbageSchedule;
import com.gramconnect.service.GarbageScheduleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/schedules")
@Tag(name = "Garbage Schedules", description = "Garbage collection schedule operations")
@CrossOrigin(origins = "*")
@SecurityRequirement(name = "bearerAuth")
public class GarbageScheduleController {
    private final GarbageScheduleService scheduleService;

    public GarbageScheduleController(GarbageScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    @GetMapping
    @Operation(summary = "Get garbage collection schedules")
    public ResponseEntity<List<GarbageSchedule>> getSchedules(
            @RequestParam(required = false) String district,
            @RequestParam(required = false) String panchayat,
            @RequestParam(required = false) String village,
            @RequestParam(required = false) String ward) {
        return ResponseEntity.ok(scheduleService.getSchedules(district, panchayat, village, ward));
    }

    @PostMapping
    @Operation(summary = "Create garbage collection schedule (admin only)")
    public ResponseEntity<GarbageSchedule> createSchedule(
            @AuthenticationPrincipal String adminId,
            @Valid @RequestBody GarbageSchedule schedule) {
        schedule.setCreatedByAdminId(adminId);
        return ResponseEntity.ok(scheduleService.createSchedule(schedule));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update garbage collection schedule (admin only)")
    public ResponseEntity<GarbageSchedule> updateSchedule(
            @PathVariable String id,
            @Valid @RequestBody GarbageSchedule schedule) {
        return ResponseEntity.ok(scheduleService.updateSchedule(id, schedule));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete garbage collection schedule (admin only)")
    public ResponseEntity<String> deleteSchedule(@PathVariable String id) {
        scheduleService.deleteSchedule(id);
        return ResponseEntity.ok("Schedule deleted successfully");
    }

    @GetMapping("/admin/{adminId}")
    @Operation(summary = "Get schedules created by admin")
    public ResponseEntity<List<GarbageSchedule>> getSchedulesByAdmin(@PathVariable String adminId) {
        return ResponseEntity.ok(scheduleService.getSchedulesByAdmin(adminId));
    }
}