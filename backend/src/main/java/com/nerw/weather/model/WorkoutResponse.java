package com.nerw.weather.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record WorkoutResponse(
        @JsonProperty("exercise_name") String exerciseName,
        List<WorkoutSet> sets
) {}
