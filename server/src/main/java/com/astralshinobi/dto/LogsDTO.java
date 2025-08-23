package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.Map;

public record LogsDTO(
        @JsonProperty("log_id") int logId,
        @JsonProperty("user_id") Integer userId,
        @JsonProperty("action_type") String actionType,
        Map<String, Object> details,
        Instant timestamp
) {}
