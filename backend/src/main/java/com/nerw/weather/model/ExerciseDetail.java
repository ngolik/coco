package com.nerw.weather.model;

import java.util.List;

public record ExerciseDetail(
        String name,
        List<SetDetail> sets
) {}
