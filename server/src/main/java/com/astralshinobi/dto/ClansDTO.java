package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.Map;

public record ClansDTO(
        @JsonProperty("clan_id") int clanId,
        String name,
        @JsonProperty("leader_id") int leaderId,
        @JsonProperty("created_at") Instant createdAt,
        int level,
        @JsonProperty("war_points") int warPoints,
        @JsonProperty("village_level") int villageLevel,
        Map<String, Object> resources
) {}
