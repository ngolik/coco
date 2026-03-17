package com.nerw.weather.model;

import java.util.List;

public record ProgressResponse(
        String userId,
        String from,
        String to,
        int totalWorkouts,
        double totalVolume,
        List<ExerciseProgress> exerciseProgress
) {
    public record ExerciseProgress(
            String exerciseId,
            String exerciseName,
            SessionSummary firstSession,
            SessionSummary lastSession,
            double volumeDeltaPct
    ) {}

    public record SessionSummary(
            String date,
            double maxWeightKg,
            double totalVolume
    ) {}
}
