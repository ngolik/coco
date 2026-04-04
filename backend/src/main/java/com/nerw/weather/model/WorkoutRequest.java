package com.nerw.weather.model;

public record WorkoutRequest(
        String exerciseName,
        double oneRepMax,
        double targetIntensityPct,
        int sets,
        int repsPerSet,
        ExerciseType exerciseType
) {}
