package com.gramconnect.repository;

import com.gramconnect.model.LocationData;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LocationDataRepository extends MongoRepository<LocationData, String> {
    List<LocationData> findByStateAndIsActiveTrue(String state);
    List<LocationData> findByDistrictAndIsActiveTrue(String district);
    List<LocationData> findByStateAndDistrictAndIsActiveTrue(String state, String district);
    LocationData findByStateAndDistrictAndPanchayatAndIsActiveTrue(String state, String district, String panchayat);
}