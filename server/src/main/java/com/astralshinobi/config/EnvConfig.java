package com.astralshinobi.config;

import io.github.cdimascio.dotenv.Dotenv;

public class EnvConfig {
    private static final Dotenv dotenv = Dotenv.configure()
            .directory("./")
            .load();

    public static int getServerPort() {
        return Integer.parseInt(dotenv.get("SERVER_PORT", "8080"));
    }

    public static String getDbUrl() {
        return dotenv.get("DB_URL");
    }

    public static String getDbUsername() {
        return dotenv.get("DB_USERNAME");
    }

    public static String getDbPassword() {
        return dotenv.get("DB_PASSWORD");
    }
}
