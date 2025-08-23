package com.astralshinobi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.List;
import java.util.Map;

public record EventsDTO(
        @JsonProperty("event_id") int eventId,
        String type,
        @JsonProperty("start_at") Instant startAt,
        @JsonProperty("end_at") Instant endAt,
        @JsonProperty("server_impact") Map<String, Object> serverImpact,
        List<Integer> participants
) {}
