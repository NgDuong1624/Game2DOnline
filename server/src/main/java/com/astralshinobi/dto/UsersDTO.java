package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;

public record UsersDTO(
        @JsonProperty("user_id") int userId,
        String username,
        @JsonProperty("password_hash") String passwordHash,
        String email,
        @JsonProperty("created_at") Instant createdAt,
        @JsonProperty("last_login") Instant lastLogin,
        String platform,
        @JsonProperty("is_premium") boolean isPremium,
        @JsonProperty("ar_access") boolean arAccess,
        @JsonProperty("is_active") boolean isActive
) {}
