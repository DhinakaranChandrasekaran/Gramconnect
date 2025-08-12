package com.gramconnect.controller;

import com.gramconnect.service.FileStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/files")
@CrossOrigin(origins = "*")
public class FileController {

    @Autowired
    private FileStorageService fileStorageService;

    @GetMapping("/images/{filename}")
    public ResponseEntity<byte[]> getImage(@PathVariable String filename) {
        try {
            byte[] image = fileStorageService.getImage(filename);
            return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_JPEG)
                .body(image);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}