package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.Map;

public record CharactersDTO(
        @JsonProperty("character_id") int characterId,
        @JsonProperty("user_id") int userId,
        String name,
        String classType,
        int level,
        long exp,
        int strength,
        int dexterity,
        int vitality,
        int chakra,
        @JsonProperty("fusion_points") int fusionPoints,
        @JsonProperty("position_x") float positionX,
        @JsonProperty("position_y") float positionY,
        @JsonProperty("map_id") int mapId,
        Map<String, Object> appearance,
        @JsonProperty("created_at") Instant createdAt
) {}
