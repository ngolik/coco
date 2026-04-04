package com.nerw.weather.model;

public record WorkoutSet(
        int setNumber,
        double workingWeight,
        int reps,
        int restSeconds
) {}
