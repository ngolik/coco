package com.nerw.weather.model;

public record WorkoutResponse(
        String workoutId,
        String userId,
        String date,
        int durationMinutes,
        int totalSets,
        double totalVolume,
        String message
) {}
