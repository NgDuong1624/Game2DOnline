package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;

public record MapsDTO(
        @JsonProperty("map_id") int mapId,
        String name,
        String status,
        @JsonProperty("cycle_end") Instant cycleEnd,
        String description
) {}