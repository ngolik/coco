package com.nerw.weather.controller;

import com.nerw.weather.model.WorkoutRequest;
import com.nerw.weather.model.WorkoutResponse;
import com.nerw.weather.service.WorkoutPlanService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/workout")
public class WorkoutController {

    private final WorkoutPlanService workoutPlanService;

    public WorkoutController(WorkoutPlanService workoutPlanService) {
        this.workoutPlanService = workoutPlanService;
    }

    @PostMapping("/plan")
    public ResponseEntity<WorkoutResponse> generatePlan(@RequestBody WorkoutRequest request) {
        WorkoutResponse response = workoutPlanService.generatePlan(request);
        return ResponseEntity.ok(response);
    }
}
