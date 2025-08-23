package com.gramconnect.util;

import java.security.SecureRandom;

public class OtpGenerator {
    private static final SecureRandom random = new SecureRandom();

    public static String generate() {
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}