package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;

public record CharacterSkillsDTO(
        @JsonProperty("char_skill_id") int charSkillId,
        @JsonProperty("character_id") int characterId,
        @JsonProperty("skill_id") int skillId,
        int level,
        @JsonProperty("is_fused") boolean isFused,
        @JsonProperty("learned_at") Instant learnedAt
) {}
