package com.nerw.weather.controller;

import com.nerw.weather.model.ExercisesResponse;
import com.nerw.weather.model.ProgressResponse;
import com.nerw.weather.model.WorkoutRequest;
import com.nerw.weather.model.WorkoutResponse;
import com.nerw.weather.service.FitnessService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/fitness")
public class FitnessController {

    private final FitnessService fitnessService;

    public FitnessController(FitnessService fitnessService) {
        this.fitnessService = fitnessService;
    }

    @GetMapping("/exercises")
    public ResponseEntity<ExercisesResponse> getExercises(
            @RequestParam(required = false) String muscleGroup,
            @RequestParam(required = false) String equipment) {
        return ResponseEntity.ok(fitnessService.listExercises(muscleGroup, equipment));
    }

    @PostMapping("/workouts")
    public ResponseEntity<WorkoutResponse> logWorkout(@RequestBody WorkoutRequest request) {
        WorkoutResponse response = fitnessService.logWorkout(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/progress")
    public ResponseEntity<ProgressResponse> getProgress(
            @RequestParam String userId,
            @RequestParam String from,
            @RequestParam String to,
            @RequestParam(required = false) String exerciseId) {
        return ResponseEntity.ok(fitnessService.getProgress(userId, from, to, exerciseId));
    }
}
