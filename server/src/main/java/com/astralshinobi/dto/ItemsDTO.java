package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Map;

public record ItemsDTO(
        @JsonProperty("item_id") int itemId,
        String name,
        String type,
        String rarity,
        String description,
        Map<String, Object> stats,
        @JsonProperty("enchant_max") int enchantMax,
        int sockets,
        int price
) {}
