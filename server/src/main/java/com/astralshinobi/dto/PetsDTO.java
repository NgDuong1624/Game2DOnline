package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Map;

public record PetsDTO(
        @JsonProperty("pet_id") int petId,
        @JsonProperty("character_id") int characterId,
        String name,
        String type,
        int level,
        @JsonProperty("ai_level") int aiLevel,
        @JsonProperty("evolution_stage") int evolutionStage,
        Map<String, Object> stats,
        boolean active
) {}
