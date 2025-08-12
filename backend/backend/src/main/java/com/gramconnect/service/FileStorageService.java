package com.gramconnect.service;

import org.springframework.stereotype.Service;
import java.util.Base64;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
public class FileStorageService {

    private final String uploadDir = "uploads/images/";

    public String saveImage(String base64Image) {
        try {
            // Create upload directory if it doesn't exist
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // Remove data URL prefix if present
            String base64Data = base64Image;
            if (base64Image.contains(",")) {
                base64Data = base64Image.split(",")[1];
            }

            // Decode base64
            byte[] imageBytes = Base64.getDecoder().decode(base64Data);

            // Generate unique filename
            String filename = UUID.randomUUID().toString() + ".jpg";
            Path filePath = uploadPath.resolve(filename);

            // Save file
            Files.write(filePath, imageBytes);

            // Return relative path/URL
            return "/api/files/images/" + filename;

        } catch (IOException e) {
            throw new RuntimeException("Failed to save image: " + e.getMessage());
        }
    }

    public byte[] getImage(String filename) {
        try {
            Path filePath = Paths.get(uploadDir).resolve(filename);
            return Files.readAllBytes(filePath);
        } catch (IOException e) {
            throw new RuntimeException("Failed to read image: " + e.getMessage());
        }
    }
}