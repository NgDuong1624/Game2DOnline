package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;

public record SessionsDTO(
        @JsonProperty("session_id") int sessionId,
        @JsonProperty("user_id") int userId,
        String token,
        String platform,
        @JsonProperty("login_at") Instant loginAt,
        @JsonProperty("logout_at") Instant logoutAt,
        @JsonProperty("is_online") boolean isOnline
) {}
