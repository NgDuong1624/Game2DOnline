package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.Map;

public record QuestProgressDTO(
        @JsonProperty("progress_id") int progressId,
        @JsonProperty("character_id") int characterId,
        @JsonProperty("quest_id") int questId,
        String status,
        @JsonProperty("progress_data") Map<String, Object> progressData,
        @JsonProperty("branch_choice") String branchChoice,
        @JsonProperty("completed_at") Instant completedAt,
        @JsonProperty("reset_at") Instant resetAt
) {}
