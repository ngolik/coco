package com.nerw.weather.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record WorkoutPlanRequest(
        @JsonProperty("bench_press_1rm") double benchPress1rm,
        @JsonProperty("squat_1rm") double squat1rm,
        @JsonProperty("deadlift_1rm") double deadlift1rm
) {}
