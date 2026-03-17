package com.nerw.weather.model;

import java.util.List;

public record WorkoutRequest(
        String userId,
        String date,
        int durationMinutes,
        List<WorkoutSet> sets,
        String notes
) {}
