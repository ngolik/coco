package com.nerw.weather.exception;

public class ExerciseNotFoundException extends RuntimeException {

    private final String exerciseId;

    public ExerciseNotFoundException(String exerciseId) {
        super("Exercise '" + exerciseId + "' not found");
        this.exerciseId = exerciseId;
    }

    public String getExerciseId() {
        return exerciseId;
    }
}
