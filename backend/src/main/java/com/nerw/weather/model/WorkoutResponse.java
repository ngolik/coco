package com.nerw.weather.model;

import java.util.List;

public record WorkoutResponse(
        String exerciseName,
        List<WorkoutSet> sets
) {}
