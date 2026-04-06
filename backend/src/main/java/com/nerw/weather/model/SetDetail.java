package com.nerw.weather.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record SetDetail(
        int reps,
        @JsonProperty("weight_kg") double weightKg
) {}
