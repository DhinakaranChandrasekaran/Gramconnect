package com.gramconnect.controller;

import com.gramconnect.model.GarbageSchedule;
import com.gramconnect.service.GarbageScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/garbage-schedules")
@CrossOrigin(origins = "*")
public class GarbageScheduleController {

    @Autowired
    private GarbageScheduleService garbageScheduleService;

    // Get schedules by village (panchayat) - matches Flutter frontend
    @GetMapping("/village/{village}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public ResponseEntity<List<GarbageSchedule>> getSchedulesByVillage(@PathVariable String village) {
        List<GarbageSchedule> schedules = garbageScheduleService.getSchedulesByPanchayat(village);
        return ResponseEntity.ok(schedules);
    }

    // Get schedules by village and ward - matches Flutter frontend
    @GetMapping("/village/{village}/ward/{ward}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public ResponseEntity<List<GarbageSchedule>> getSchedulesByVillageAndWard(
            @PathVariable String village,
            @PathVariable String ward) {
        List<GarbageSchedule> schedules = garbageScheduleService.getSchedulesByPanchayatAndWard(village, ward);
        return ResponseEntity.ok(schedules);
    }

    // Legacy endpoints for backward compatibility
    @GetMapping("/district/{district}/panchayat/{panchayat}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public ResponseEntity<List<GarbageSchedule>> getSchedulesByPanchayat(
            @PathVariable String district,
            @PathVariable String panchayat) {
        List<GarbageSchedule> schedules = garbageScheduleService.getSchedulesByDistrictAndPanchayat(district, panchayat);
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/district/{district}/panchayat/{panchayat}/ward/{ward}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public ResponseEntity<List<GarbageSchedule>> getSchedulesByPanchayatAndWard(
            @PathVariable String district,
            @PathVariable String panchayat,
            @PathVariable String ward) {
        List<GarbageSchedule> schedules = garbageScheduleService.getSchedulesByDistrictPanchayatAndWard(district, panchayat, ward);
        return ResponseEntity.ok(schedules);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createSchedule(@RequestBody GarbageSchedule schedule) {
        try {
            GarbageSchedule created = garbageScheduleService.createSchedule(schedule);
            return ResponseEntity.ok(Map.of("success", true, "data", created));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateSchedule(@PathVariable String id, @RequestBody GarbageSchedule schedule) {
        try {
            GarbageSchedule updated = garbageScheduleService.updateSchedule(id, schedule);
            return ResponseEntity.ok(Map.of("success", true, "data", updated));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteSchedule(@PathVariable String id) {
        try {
            garbageScheduleService.deleteSchedule(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Schedule deleted successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<GarbageSchedule>> getAllSchedules() {
        List<GarbageSchedule> schedules = garbageScheduleService.getAllSchedules();
        return ResponseEntity.ok(schedules);
    }
}