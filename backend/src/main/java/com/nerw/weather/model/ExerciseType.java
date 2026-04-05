package com.nerw.weather.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public enum ExerciseType {
    @JsonProperty("single-joint") SINGLE_JOINT,
    @JsonProperty("multi-joint") MULTI_JOINT
}
