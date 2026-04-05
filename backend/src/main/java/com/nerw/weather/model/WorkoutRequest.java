package com.nerw.weather.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record WorkoutRequest(
        @JsonProperty("exercise_name") String exerciseName,
        @JsonProperty("one_rm_kg") double oneRepMax,
        @JsonProperty("target_intensity_pct") double targetIntensityPct,
        @JsonProperty("num_sets") int sets,
        @JsonProperty("reps_per_set") int repsPerSet,
        @JsonProperty("exercise_type") ExerciseType exerciseType
) {}
