package com.gramconnect.service;

import com.gramconnect.model.GarbageSchedule;
import com.gramconnect.repository.GarbageScheduleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class GarbageScheduleService {

    @Autowired
    private GarbageScheduleRepository garbageScheduleRepository;

    // For Flutter frontend - get schedules by panchayat (village)
    public List<GarbageSchedule> getSchedulesByPanchayat(String panchayat) {
        return garbageScheduleRepository.findByPanchayatAndIsActiveTrue(panchayat);
    }

    // For Flutter frontend - get schedules by panchayat and ward
    public List<GarbageSchedule> getSchedulesByPanchayatAndWard(String panchayat, String ward) {
        return garbageScheduleRepository.findByPanchayatAndWardAndIsActiveTrue(panchayat, ward);
    }

    // Legacy methods for backward compatibility
    public List<GarbageSchedule> getSchedulesByDistrictAndPanchayat(String district, String panchayat) {
        return garbageScheduleRepository.findByDistrictAndPanchayatAndIsActiveTrue(district, panchayat);
    }

    public List<GarbageSchedule> getSchedulesByDistrictPanchayatAndWard(String district, String panchayat, String ward) {
        return garbageScheduleRepository.findByDistrictAndPanchayatAndWardAndIsActiveTrue(district, panchayat, ward);
    }

    public GarbageSchedule createSchedule(GarbageSchedule schedule) {
        if (schedule.getDistrict() == null || schedule.getDistrict().isBlank()) {
            throw new RuntimeException("District is required");
        }
        if (schedule.getPanchayat() == null || schedule.getPanchayat().isBlank()) {
            throw new RuntimeException("Panchayat is required");
        }
        if (schedule.getCollectionDays() == null || schedule.getCollectionDays().isEmpty()) {
            throw new RuntimeException("Collection days are required");
        }
        if (schedule.getPickupTime() == null) {
            throw new RuntimeException("Pickup time is required");
        }
        
        return garbageScheduleRepository.save(schedule);
    }

    public GarbageSchedule updateSchedule(String id, GarbageSchedule schedule) {
        Optional<GarbageSchedule> existingSchedule = garbageScheduleRepository.findById(id);
        if (existingSchedule.isEmpty()) {
            throw new RuntimeException("Schedule not found");
        }

        GarbageSchedule updated = existingSchedule.get();

        if (schedule.getDistrict() != null) updated.setDistrict(schedule.getDistrict());
        if (schedule.getPanchayat() != null) updated.setPanchayat(schedule.getPanchayat());
        if (schedule.getWard() != null) updated.setWard(schedule.getWard());
        if (schedule.getArea() != null) updated.setArea(schedule.getArea());
        if (schedule.getCollectionDays() != null) updated.setCollectionDays(schedule.getCollectionDays());
        if (schedule.getPickupTime() != null) updated.setPickupTime(schedule.getPickupTime());
        if (schedule.getDescription() != null) updated.setDescription(schedule.getDescription());

        return garbageScheduleRepository.save(updated);
    }

    public void deleteSchedule(String id) {
        Optional<GarbageSchedule> schedule = garbageScheduleRepository.findById(id);
        if (schedule.isPresent()) {
            GarbageSchedule existing = schedule.get();
            existing.setActive(false);
            garbageScheduleRepository.save(existing);
        } else {
            throw new RuntimeException("Schedule not found");
        }
    }

    public List<GarbageSchedule> getAllSchedules() {
        return garbageScheduleRepository.findAll();
    }

    public long getActiveSchedulesCount() {
        return garbageScheduleRepository.findAll().stream()
                .mapToLong(schedule -> schedule.isActive() ? 1 : 0)
                .sum();
    }
}