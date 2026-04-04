package com.nerw.weather.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record WorkoutRequest(
        String exerciseName,
        @JsonProperty("one_rm_kg") double oneRepMax,
        double targetIntensityPct,
        @JsonProperty("num_sets") int sets,
        int repsPerSet,
        ExerciseType exerciseType
) {}
