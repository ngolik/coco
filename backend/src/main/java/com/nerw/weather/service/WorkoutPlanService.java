package com.nerw.weather.service;

import com.nerw.weather.exception.InvalidRequestException;
import com.nerw.weather.model.ExerciseType;
import com.nerw.weather.model.WorkoutRequest;
import com.nerw.weather.model.WorkoutResponse;
import com.nerw.weather.model.WorkoutSet;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class WorkoutPlanService {

    /**
     * Calculates working weight rounded to nearest 2.5 kg increment.
     */
    double calculateWorkingWeight(double oneRepMax, double targetIntensityPct) {
        double raw = oneRepMax * targetIntensityPct / 100.0;
        return Math.round(raw / 2.5) * 2.5;
    }

    /**
     * Interpolates base rest seconds from intensity percentage.
     * Breakpoints: 30% → 90s, 70% → 180s, 90% → 360s
     * Clamped outside the [30, 90] range.
     */
    double calculateBaseRestSeconds(double intensityPct) {
        if (intensityPct <= 30) {
            return 90;
        } else if (intensityPct <= 70) {
            // linear interpolation between 30%→90s and 70%→180s
            double t = (intensityPct - 30) / (70 - 30);
            return 90 + t * (180 - 90);
        } else if (intensityPct <= 90) {
            // linear interpolation between 70%→180s and 90%→360s
            double t = (intensityPct - 70) / (90 - 70);
            return 180 + t * (360 - 180);
        } else {
            return 360;
        }
    }

    /**
     * Returns exercise coefficient: SINGLE_JOINT → 0.35, MULTI_JOINT → 1.4
     */
    double exerciseCoeff(ExerciseType type) {
        return type == ExerciseType.SINGLE_JOINT ? 0.35 : 1.4;
    }

    /**
     * Rounds a value to the nearest multiple of 15.
     */
    int roundToNearest15(double value) {
        return (int) (Math.round(value / 15.0) * 15);
    }

    public WorkoutResponse generatePlan(WorkoutRequest request) {
        validateRequest(request);

        double workingWeight = calculateWorkingWeight(request.oneRepMax(), request.targetIntensityPct());
        double baseRest = calculateBaseRestSeconds(request.targetIntensityPct());
        double coeff = exerciseCoeff(request.exerciseType());
        int restSeconds = roundToNearest15(baseRest * coeff);

        List<WorkoutSet> sets = new ArrayList<>();
        for (int i = 1; i <= request.sets(); i++) {
            sets.add(new WorkoutSet(i, workingWeight, request.repsPerSet(), restSeconds));
        }

        return new WorkoutResponse(request.exerciseName(), sets);
    }

    private void validateRequest(WorkoutRequest request) {
        if (request.exerciseName() == null || request.exerciseName().isBlank()) {
            throw new InvalidRequestException("exerciseName must not be blank");
        }
        if (request.oneRepMax() <= 0) {
            throw new InvalidRequestException("oneRepMax must be positive");
        }
        if (request.targetIntensityPct() < 30 || request.targetIntensityPct() > 100) {
            throw new InvalidRequestException("targetIntensityPct must be between 30 and 100");
        }
        if (request.sets() < 3 || request.sets() > 5) {
            throw new InvalidRequestException("sets must be between 3 and 5");
        }
        if (request.repsPerSet() <= 0) {
            throw new InvalidRequestException("repsPerSet must be positive");
        }
        if (request.exerciseType() == null) {
            throw new InvalidRequestException("exerciseType must not be null");
        }
    }
}
