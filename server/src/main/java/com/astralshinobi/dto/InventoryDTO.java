package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public record InventoryDTO(
        @JsonProperty("inventory_id") int inventoryId,
        @JsonProperty("character_id") int characterId,
        @JsonProperty("item_id") int itemId,
        int quantity,
        @JsonProperty("enchant_level") int enchantLevel,
        List<Integer> gems,
        boolean equipped
) {}
