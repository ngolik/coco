package com.nerw.weather.model;

public record WorkoutSet(
        String exerciseId,
        int reps,
        double weightKg,
        int setNumber  // preserved for future set-ordering logic
) {}
