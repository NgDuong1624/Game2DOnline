package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;

public record PvPRecordsDTO(
        @JsonProperty("pvp_id") int pvpId,
        @JsonProperty("character_id") int characterId,
        int wins,
        int losses,
        int rank,
        @JsonProperty("last_fight") Instant lastFight
) {}
