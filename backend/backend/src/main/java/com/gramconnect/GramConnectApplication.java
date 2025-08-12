package com.gramconnect;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.config.EnableMongoAuditing;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import com.gramconnect.service.LocationService;

@SpringBootApplication
@EnableMongoAuditing
@EnableScheduling
public class GramConnectApplication implements CommandLineRunner {

    @Autowired
    private LocationService locationService;

    public static void main(String[] args) {
        SpringApplication.run(GramConnectApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        // Initialize location data on startup
        locationService.initializeLocationData();
    }
}