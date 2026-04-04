package com.nerw.weather.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record WorkoutSet(
        int setNumber,
        @JsonProperty("working_weight_kg") double workingWeight,
        int reps,
        @JsonProperty("rest_time_sec") int restSeconds
) {}
