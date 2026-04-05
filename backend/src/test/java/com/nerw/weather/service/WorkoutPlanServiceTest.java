package com.nerw.weather.service;

import com.nerw.weather.exception.InvalidRequestException;
import com.nerw.weather.model.ExerciseType;
import com.nerw.weather.model.WorkoutRequest;
import com.nerw.weather.model.WorkoutResponse;
import com.nerw.weather.model.WorkoutSet;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class WorkoutPlanServiceTest {

    private WorkoutPlanService service;

    @BeforeEach
    void setUp() {
        service = new WorkoutPlanService();
    }

    // --- calculateWorkingWeight ---

    @Test
    void workingWeight_roundsToNearest2_5() {
        // 100 * 75% = 75.0 → already a multiple of 2.5
        assertEquals(75.0, service.calculateWorkingWeight(100, 75));
    }

    @Test
    void workingWeight_roundsUp() {
        // 100 * 76% = 76 → nearest 2.5 multiple = 75.0? Let's compute:
        // 76 / 2.5 = 30.4 → round = 30 → 30 * 2.5 = 75.0
        assertEquals(75.0, service.calculateWorkingWeight(100, 76));
    }

    @Test
    void workingWeight_roundsUpLargeValue() {
        // 120 * 80% = 96 → 96 / 2.5 = 38.4 → round = 38 → 38 * 2.5 = 95.0
        assertEquals(95.0, service.calculateWorkingWeight(120, 80));
    }

    @Test
    void workingWeight_exactMultiple() {
        // 200 * 50% = 100 → 100.0
        assertEquals(100.0, service.calculateWorkingWeight(200, 50));
    }

    // --- calculateBaseRestSeconds ---

    @Test
    void baseRest_at30pct_returns90() {
        assertEquals(90.0, service.calculateBaseRestSeconds(30), 0.001);
    }

    @Test
    void baseRest_at70pct_returns180() {
        assertEquals(180.0, service.calculateBaseRestSeconds(70), 0.001);
    }

    @Test
    void baseRest_at90pct_returns360() {
        assertEquals(360.0, service.calculateBaseRestSeconds(90), 0.001);
    }

    @Test
    void baseRest_at50pct_interpolatesBetween30and70() {
        // midpoint between 30%→90s and 70%→180s: (90+180)/2 = 135
        assertEquals(135.0, service.calculateBaseRestSeconds(50), 0.001);
    }

    @Test
    void baseRest_at80pct_interpolatesBetween70and90() {
        // midpoint between 70%→180s and 90%→360s: (180+360)/2 = 270
        assertEquals(270.0, service.calculateBaseRestSeconds(80), 0.001);
    }

    @Test
    void baseRest_below30_clampedTo90() {
        assertEquals(90.0, service.calculateBaseRestSeconds(10), 0.001);
    }

    @Test
    void baseRest_above90_clampedTo360() {
        assertEquals(360.0, service.calculateBaseRestSeconds(100), 0.001);
    }

    // --- exerciseCoeff ---

    @Test
    void exerciseCoeff_singleJoint_returns0_35() {
        assertEquals(0.35, service.exerciseCoeff(ExerciseType.SINGLE_JOINT), 0.001);
    }

    @Test
    void exerciseCoeff_multiJoint_returns1_4() {
        assertEquals(1.4, service.exerciseCoeff(ExerciseType.MULTI_JOINT), 0.001);
    }

    // --- roundToNearest15 ---

    @Test
    void roundToNearest15_exact() {
        assertEquals(90, service.roundToNearest15(90));
    }

    @Test
    void roundToNearest15_roundsUp() {
        assertEquals(105, service.roundToNearest15(100));
    }

    @Test
    void roundToNearest15_roundsDown() {
        assertEquals(90, service.roundToNearest15(92));
    }

    @Test
    void roundToNearest15_midpoint() {
        // 97.5 is exactly halfway between 90 and 105 → rounds to 105 (half-up)
        assertEquals(105, service.roundToNearest15(97.5));
    }

    // --- generatePlan integration ---

    @Test
    void generatePlan_correctNumberOfSets() {
        WorkoutRequest req = new WorkoutRequest("Bench Press", 100, 70, 3, 8, ExerciseType.MULTI_JOINT);
        WorkoutResponse resp = service.generatePlan(req);
        assertEquals(3, resp.sets().size());
    }

    @Test
    void generatePlan_setsNumberedSequentially() {
        WorkoutRequest req = new WorkoutRequest("Squat", 150, 80, 4, 5, ExerciseType.MULTI_JOINT);
        WorkoutResponse resp = service.generatePlan(req);
        List<WorkoutSet> sets = resp.sets();
        for (int i = 0; i < sets.size(); i++) {
            assertEquals(i + 1, sets.get(i).setNumber());
        }
    }

    @Test
    void generatePlan_allSetsHaveSameWeightAndReps() {
        WorkoutRequest req = new WorkoutRequest("Deadlift", 200, 75, 3, 5, ExerciseType.MULTI_JOINT);
        WorkoutResponse resp = service.generatePlan(req);
        double expectedWeight = service.calculateWorkingWeight(200, 75);
        for (WorkoutSet s : resp.sets()) {
            assertEquals(expectedWeight, s.workingWeight(), 0.001);
            assertEquals(5, s.reps());
        }
    }

    @Test
    void generatePlan_multiJoint_restAtHighIntensity() {
        // intensity 90%, baseRest=360, coeff=1.4 → 504 → nearest 15 = 510
        WorkoutRequest req = new WorkoutRequest("Squat", 100, 90, 3, 3, ExerciseType.MULTI_JOINT);
        WorkoutResponse resp = service.generatePlan(req);
        assertEquals(510, resp.sets().get(0).restSeconds());
    }

    @Test
    void generatePlan_singleJoint_restAtLowIntensity() {
        // intensity 30%, baseRest=90, coeff=0.35 → 31.5 → nearest 15 = 30
        WorkoutRequest req = new WorkoutRequest("Curl", 50, 30, 3, 12, ExerciseType.SINGLE_JOINT);
        WorkoutResponse resp = service.generatePlan(req);
        assertEquals(30, resp.sets().get(0).restSeconds());
    }

    @Test
    void generatePlan_exerciseNamePreserved() {
        WorkoutRequest req = new WorkoutRequest("Pull Up", 80, 60, 3, 6, ExerciseType.MULTI_JOINT);
        WorkoutResponse resp = service.generatePlan(req);
        assertEquals("Pull Up", resp.exerciseName());
    }

    // --- validation ---

    @Test
    void validation_blankExerciseName_throws() {
        WorkoutRequest req = new WorkoutRequest("", 100, 70, 3, 8, ExerciseType.MULTI_JOINT);
        assertThrows(InvalidRequestException.class, () -> service.generatePlan(req));
    }

    @Test
    void validation_zeroOneRepMax_throws() {
        WorkoutRequest req = new WorkoutRequest("Squat", 0, 70, 3, 8, ExerciseType.MULTI_JOINT);
        assertThrows(InvalidRequestException.class, () -> service.generatePlan(req));
    }

    @Test
    void validation_intensityBelow30_throws() {
        WorkoutRequest req = new WorkoutRequest("Squat", 100, 20, 3, 8, ExerciseType.MULTI_JOINT);
        assertThrows(InvalidRequestException.class, () -> service.generatePlan(req));
    }

    @Test
    void validation_intensityAbove100_throws() {
        WorkoutRequest req = new WorkoutRequest("Squat", 100, 101, 3, 8, ExerciseType.MULTI_JOINT);
        assertThrows(InvalidRequestException.class, () -> service.generatePlan(req));
    }

    @Test
    void validation_setsBelow3_throws() {
        WorkoutRequest req = new WorkoutRequest("Squat", 100, 70, 2, 8, ExerciseType.MULTI_JOINT);
        assertThrows(InvalidRequestException.class, () -> service.generatePlan(req));
    }

    @Test
    void validation_setsAbove5_throws() {
        WorkoutRequest req = new WorkoutRequest("Squat", 100, 70, 6, 8, ExerciseType.MULTI_JOINT);
        assertThrows(InvalidRequestException.class, () -> service.generatePlan(req));
    }

    @Test
    void validation_zeroRepsPerSet_throws() {
        WorkoutRequest req = new WorkoutRequest("Squat", 100, 70, 3, 0, ExerciseType.MULTI_JOINT);
        assertThrows(InvalidRequestException.class, () -> service.generatePlan(req));
    }

    @Test
    void validation_nullExerciseType_throws() {
        WorkoutRequest req = new WorkoutRequest("Squat", 100, 70, 3, 8, null);
        assertThrows(InvalidRequestException.class, () -> service.generatePlan(req));
    }
}
