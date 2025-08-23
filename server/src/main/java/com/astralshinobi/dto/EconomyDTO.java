package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record EconomyDTO(
        @JsonProperty("economy_id") int economyId,
        @JsonProperty("character_id") int characterId,
        @JsonProperty("currency_type") String currencyType,
        long amount
) {}
