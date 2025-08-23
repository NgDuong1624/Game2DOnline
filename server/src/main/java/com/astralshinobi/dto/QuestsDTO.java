package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Map;

public record QuestsDTO(
        @JsonProperty("quest_id") int questId,
        String name,
        String type,
        String description,
        @JsonProperty("level_req") int levelReq,
        @JsonProperty("branch_options") Map<String, Object> branchOptions,
        Map<String, Object> rewards
) {}
