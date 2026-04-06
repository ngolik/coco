package com.nerw.weather.model;

import java.util.List;

public record TrainingDay(
        int day,
        List<ExerciseDetail> exercises
) {}
