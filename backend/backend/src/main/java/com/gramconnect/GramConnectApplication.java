package com.gramconnect;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.data.mongodb.config.EnableMongoAuditing;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
@EnableMongoAuditing
@EnableAsync
@EnableWebSecurity
public class GramConnectApplication {

    public static void main(String[] args) {
        SpringApplication.run(GramConnectApplication.class, args);
        System.out.println("🔶 GramConnect Backend Started Successfully! 🔶");
        System.out.println("📖 API Documentation: http://localhost:8080/swagger-ui.html");
        System.out.println("🔐 Remember to seed Super Admin: POST /api/admins/seed");
    }
}