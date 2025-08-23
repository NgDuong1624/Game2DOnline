package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Map;

public record SkillsDTO(
        @JsonProperty("skill_id") int skillId,
        String name,
        String type,
        @JsonProperty("class_req") String classReq,
        @JsonProperty("level_req") int levelReq,
        String description,
        @JsonProperty("fusion_req") Map<String, Object> fusionReq,
        Map<String, Object> cost
) {}
