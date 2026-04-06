package com.nerw.weather.model;

import java.util.List;

public record MicrocycleResponse(
        int microcycle,
        List<TrainingDay> days
) {}
