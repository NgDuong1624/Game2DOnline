package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record ClanMembersDTO(
        @JsonProperty("member_id") int memberId,
        @JsonProperty("clan_id") int clanId,
        @JsonProperty("character_id") int characterId,
        String role
) {}
