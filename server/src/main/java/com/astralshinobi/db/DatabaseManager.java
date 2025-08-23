package com.astralshinobi.db;

import com.astralshinobi.config.EnvConfig;
import com.astralshinobi.dto.UsersDTO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DatabaseManager {
    private static Connection connection;

    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            String url = EnvConfig.getDbUrl();
            String username = EnvConfig.getDbUsername();
            String password = EnvConfig.getDbPassword();
            connection = DriverManager.getConnection(url, username, password);
        }
        return connection;
    }

    // Ví dụ: Lấy UsersDTO từ DB
    public static UsersDTO getUserById(int userId) throws SQLException {
        String query = "SELECT * FROM Users WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new UsersDTO(
                        rs.getInt("user_id"),
                        rs.getString("username"),
                        rs.getString("password_hash"),
                        rs.getString("email"),
                        rs.getTimestamp("created_at").toInstant(),
                        rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login").toInstant() : null,
                        rs.getString("platform"),
                        rs.getBoolean("is_premium"),
                        rs.getBoolean("ar_access"),
                        rs.getBoolean("is_active")
                );
            }
        }
        return null;
    }
}