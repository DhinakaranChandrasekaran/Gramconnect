package com.gramconnect.service;

import com.gramconnect.model.GarbageSchedule;
import com.gramconnect.repository.GarbageScheduleRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class GarbageScheduleService {
    private final GarbageScheduleRepository scheduleRepository;

    public GarbageScheduleService(GarbageScheduleRepository scheduleRepository) {
        this.scheduleRepository = scheduleRepository;
    }

    public List<GarbageSchedule> getSchedules(String district, String panchayat, String village, String ward) {
        if (ward != null) {
            return scheduleRepository.findByDistrictAndPanchayatAndVillageAndWard(district, panchayat, village, ward);
        } else if (village != null) {
            return scheduleRepository.findByDistrictAndPanchayatAndVillage(district, panchayat, village);
        } else {
            return scheduleRepository.findAll();
        }
    }

    public GarbageSchedule createSchedule(GarbageSchedule schedule) {
        return scheduleRepository.save(schedule);
    }

    public GarbageSchedule updateSchedule(String id, GarbageSchedule updatedSchedule) {
        GarbageSchedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Schedule not found"));

        schedule.setDays(updatedSchedule.getDays());
        schedule.setTime(updatedSchedule.getTime());
        schedule.setAreaPolygon(updatedSchedule.getAreaPolygon());

        return scheduleRepository.save(schedule);
    }

    public void deleteSchedule(String id) {
        if (!scheduleRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Schedule not found");
        }
        scheduleRepository.deleteById(id);
    }

    public List<GarbageSchedule> getSchedulesByAdmin(String adminId) {
        return scheduleRepository.findByCreatedByAdminId(adminId);
    }
}