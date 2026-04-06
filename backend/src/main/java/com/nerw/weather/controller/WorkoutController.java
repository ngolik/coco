package com.nerw.weather.controller;

import com.nerw.weather.model.MicrocycleResponse;
import com.nerw.weather.model.WorkoutPlanRequest;
import com.nerw.weather.service.WorkoutPlanService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/workout")
public class WorkoutController {

    private final WorkoutPlanService workoutPlanService;

    public WorkoutController(WorkoutPlanService workoutPlanService) {
        this.workoutPlanService = workoutPlanService;
    }

    @PostMapping("/plan")
    public ResponseEntity<List<MicrocycleResponse>> generatePlan(@RequestBody WorkoutPlanRequest request) {
        List<MicrocycleResponse> plan = workoutPlanService.generatePlan(request);
        return ResponseEntity.ok(plan);
    }
}
