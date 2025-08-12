package com.gramconnect.service;

import com.gramconnect.model.LocationData;
import com.gramconnect.repository.LocationDataRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Arrays;
import java.util.Collections;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class LocationService {

    @Autowired
    private LocationDataRepository locationDataRepository;

    @PostConstruct
    public void init() {
        initializeLocationData(); // Ensure data is inserted on application startup
    }

    public List<String> getDistricts(String state) {
        List<LocationData> locations = locationDataRepository.findByStateAndIsActiveTrue(state);
        return locations.stream()
                .map(LocationData::getDistrict)
                .distinct()
                .collect(Collectors.toList());
    }

    public List<String> getPanchayats(String district) {
        List<LocationData> locations = locationDataRepository.findByDistrictAndIsActiveTrue(district);
        return locations.stream()
                .map(LocationData::getPanchayat)
                .distinct()
                .collect(Collectors.toList());
    }

    public List<String> getWards(String district, String panchayat) {
        Optional<LocationData> location = Optional.ofNullable(
            locationDataRepository.findByStateAndDistrictAndPanchayatAndIsActiveTrue("Tamil Nadu", district, panchayat)
        );
        return location.map(LocationData::getWards).orElse(Collections.emptyList());
    }

    public void initializeLocationData() {
        if (locationDataRepository.count() > 0) {
            return;
        }

        List<LocationData> locations = Arrays.asList(
            new LocationData("Tamil Nadu", "Chennai", "Alandur", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5")),
            new LocationData("Tamil Nadu", "Chennai", "Ambattur", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5")),
            new LocationData("Tamil Nadu", "Chennai", "Madhavaram", Arrays.asList("Ward 1", "Ward 2", "Ward 3")),
            new LocationData("Tamil Nadu", "Chennai", "Manali", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),
            new LocationData("Tamil Nadu", "Chennai", "Sholinganallur", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5")),

            new LocationData("Tamil Nadu", "Coimbatore", "Annur", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),
            new LocationData("Tamil Nadu", "Coimbatore", "Kinathukadavu", Arrays.asList("Ward 1", "Ward 2", "Ward 3")),
            new LocationData("Tamil Nadu", "Coimbatore", "Madukkarai", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),
            new LocationData("Tamil Nadu", "Coimbatore", "Perur", Arrays.asList("Ward 1", "Ward 2", "Ward 3")),
            new LocationData("Tamil Nadu", "Coimbatore", "Sulur", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5")),

            new LocationData("Tamil Nadu", "Madurai", "Kalligudi", Arrays.asList("Ward 1", "Ward 2", "Ward 3")),
            new LocationData("Tamil Nadu", "Madurai", "Thiruparankundram", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),
            new LocationData("Tamil Nadu", "Madurai", "Usilampatti", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5")),
            new LocationData("Tamil Nadu", "Madurai", "Vadipatti", Arrays.asList("Ward 1", "Ward 2", "Ward 3")),
            new LocationData("Tamil Nadu", "Madurai", "Melur", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),

            new LocationData("Tamil Nadu", "Salem", "Attur", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),
            new LocationData("Tamil Nadu", "Salem", "Gangavalli", Arrays.asList("Ward 1", "Ward 2", "Ward 3")),
            new LocationData("Tamil Nadu", "Salem", "Kadayampatti", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),
            new LocationData("Tamil Nadu", "Salem", "Omalur", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5")),
            new LocationData("Tamil Nadu", "Salem", "Vazhapadi", Arrays.asList("Ward 1", "Ward 2", "Ward 3")),

            new LocationData("Tamil Nadu", "Tiruchirappalli", "Lalgudi", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),
            new LocationData("Tamil Nadu", "Tiruchirappalli", "Manachanallur", Arrays.asList("Ward 1", "Ward 2", "Ward 3")),
            new LocationData("Tamil Nadu", "Tiruchirappalli", "Manapparai", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4")),
            new LocationData("Tamil Nadu", "Tiruchirappalli", "Musiri", Arrays.asList("Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5")),
            new LocationData("Tamil Nadu", "Tiruchirappalli", "Srirangam", Arrays.asList("Ward 1", "Ward 2", "Ward 3"))
        );

        locationDataRepository.saveAll(locations);
    }
}
