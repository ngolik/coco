package com.nerw.weather.service;

import com.nerw.weather.exception.InvalidRequestException;
import com.nerw.weather.model.*;
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

    // ── workingWeight ──────────────────────────────────────────────────────

    @Test
    void workingWeight_exactMultiple() {
        // 120 × 50% = 60.0 → already multiple of 2.5
        assertEquals(60.0, service.workingWeight(120, 50));
    }

    @Test
    void workingWeight_roundsUp() {
        // 120 × 62% = 74.4 → 74.4/2.5=29.76 → round=30 → 75.0
        assertEquals(75.0, service.workingWeight(120, 62));
    }

    @Test
    void workingWeight_roundsDown() {
        // 120 × 80% = 96 → 96/2.5=38.4 → round=38 → 95.0
        assertEquals(95.0, service.workingWeight(120, 80));
    }

    @Test
    void workingWeight_ohp_bench120() {
        // OHP 1rm = 120 × 0.6 = 72; @50%: 72×0.5=36 → 36/2.5=14.4 → round=14 → 35.0
        double ohp1rm = 120 * 0.6;
        assertEquals(35.0, service.workingWeight(ohp1rm, 50));
    }

    // ── exerciseOneRepMax ──────────────────────────────────────────────────

    @Test
    void oneRepMax_benchLeja() {
        assertEquals(120.0, service.exerciseOneRepMax("Жим лежа", 120, 150, 180));
    }

    @Test
    void oneRepMax_prised() {
        assertEquals(150.0, service.exerciseOneRepMax("Присед", 120, 150, 180));
    }

    @Test
    void oneRepMax_stanovaya() {
        assertEquals(180.0, service.exerciseOneRepMax("Становая тяга", 120, 150, 180));
    }

    @Test
    void oneRepMax_zhimStoya() {
        assertEquals(72.0, service.exerciseOneRepMax("Жим стоя", 120, 150, 180), 0.001);
    }

    @Test
    void oneRepMax_zhimSrednim() {
        assertEquals(108.0, service.exerciseOneRepMax("Жим средним хватом", 120, 150, 180), 0.001);
    }

    @Test
    void oneRepMax_bicepsStoya() {
        assertEquals(48.0, service.exerciseOneRepMax("Бицепс стоя", 120, 150, 180), 0.001);
    }

    @Test
    void oneRepMax_molotkovye_perDumbbell() {
        // bench/6 per dumbbell
        assertEquals(20.0, service.exerciseOneRepMax("Молотковые сгибания", 120, 150, 180), 0.001);
    }

    @Test
    void oneRepMax_zhimBezNog() {
        assertEquals(96.0, service.exerciseOneRepMax("Жим без ног", 120, 150, 180), 0.001);
    }

    @Test
    void oneRepMax_unknownExercise_throws() {
        assertThrows(InvalidRequestException.class,
                () -> service.exerciseOneRepMax("Unknown", 120, 150, 180));
    }

    // ── generatePlan structure ─────────────────────────────────────────────

    @Test
    void generatePlan_returns4Microcycles() {
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        assertEquals(4, plan.size());
    }

    @Test
    void generatePlan_microyclesNumbered1to4() {
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        for (int i = 0; i < 4; i++) {
            assertEquals(i + 1, plan.get(i).microcycle());
        }
    }

    @Test
    void generatePlan_eachMicrocycleHas3Days() {
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        for (MicrocycleResponse mc : plan) {
            assertEquals(3, mc.days().size(), "microcycle " + mc.microcycle());
        }
    }

    @Test
    void generatePlan_daysNumbered1to3() {
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        for (MicrocycleResponse mc : plan) {
            for (int i = 0; i < 3; i++) {
                assertEquals(i + 1, mc.days().get(i).day());
            }
        }
    }

    @Test
    void generatePlan_mc1Day1Has5Exercises() {
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        TrainingDay day1 = plan.get(0).days().get(0);
        assertEquals(5, day1.exercises().size());
    }

    @Test
    void generatePlan_mc1Day2Has6Exercises() {
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        TrainingDay day2 = plan.get(0).days().get(1);
        assertEquals(6, day2.exercises().size());
    }

    @Test
    void generatePlan_mc3Day3IsRest_noExercises() {
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        TrainingDay day3 = plan.get(2).days().get(2);
        assertTrue(day3.exercises().isEmpty(), "Microcycle 3 Day 3 should be a rest day");
    }

    // ── weight calculations ────────────────────────────────────────────────

    @Test
    void generatePlan_mc1Day1BenchFirstSet_50pct() {
        // Жим лежа first occurrence, first set: 1×4@50% → 120×0.5=60
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        ExerciseDetail bench = plan.get(0).days().get(0).exercises().get(0);
        assertEquals("Жим лежа", bench.name());
        assertEquals(60.0, bench.sets().get(0).weightKg(), 0.001);
        assertEquals(4, bench.sets().get(0).reps());
    }

    @Test
    void generatePlan_mc1Day1OHP_5x5at50pct() {
        // Жим стоя: 5x5@50%; OHP 1rm = 120×0.6=72; weight = ROUND(72×0.5/2.5)×2.5=35
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        ExerciseDetail ohp = plan.get(0).days().get(0).exercises().get(3);
        assertEquals("Жим стоя", ohp.name());
        assertEquals(5, ohp.sets().size());
        ohp.sets().forEach(s -> {
            assertEquals(5, s.reps());
            assertEquals(35.0, s.weightKg(), 0.001);
        });
    }

    @Test
    void generatePlan_mc1Day1MediumGrip_5x5at60pct() {
        // Жим средним хватом: 5×5@60%; 1rm=120×0.9=108; weight=ROUND(108×0.6/2.5)×2.5=65
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        ExerciseDetail mg = plan.get(0).days().get(0).exercises().get(4);
        assertEquals("Жим средним хватом", mg.name());
        assertEquals(5, mg.sets().size());
        mg.sets().forEach(s -> {
            assertEquals(5, s.reps());
            assertEquals(65.0, s.weightKg(), 0.001);
        });
    }

    @Test
    void generatePlan_mc1Day2Hammer_5x5at50pct_perDumbbell() {
        // Молотковые: 5×5@50%; per-db 1rm = 120/6=20; weight=ROUND(20×0.5/2.5)×2.5=10
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        ExerciseDetail hammer = plan.get(0).days().get(1).exercises().get(4);
        assertEquals("Молотковые сгибания", hammer.name());
        assertEquals(5, hammer.sets().size());
        hammer.sets().forEach(s -> {
            assertEquals(5, s.reps());
            assertEquals(10.0, s.weightKg(), 0.001);
        });
    }

    @Test
    void generatePlan_mc1Day2BenchNoLegs_5x5at62pct() {
        // Жим без ног: 5×5@62%; 1rm=120×0.8=96; weight=ROUND(96×0.62/2.5)×2.5=60
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        ExerciseDetail bnl = plan.get(0).days().get(1).exercises().get(5);
        assertEquals("Жим без ног", bnl.name());
        assertEquals(5, bnl.sets().size());
        bnl.sets().forEach(s -> {
            assertEquals(5, s.reps());
            assertEquals(60.0, s.weightKg(), 0.001);
        });
    }

    @Test
    void generatePlan_setGroupsExpanded() {
        // MC1 Day1 Присед: 1x3@55% + 2x2@65% + 2x1@75% + 2x1@83% = 7 total sets
        List<MicrocycleResponse> plan = service.generatePlan(req(120, 150, 180));
        ExerciseDetail squat = plan.get(0).days().get(0).exercises().get(1);
        assertEquals("Присед", squat.name());
        assertEquals(1 + 2 + 2 + 2, squat.sets().size());
    }

    // ── validation ─────────────────────────────────────────────────────────

    @Test
    void validation_zeroBench_throws() {
        assertThrows(InvalidRequestException.class,
                () -> service.generatePlan(req(0, 150, 180)));
    }

    @Test
    void validation_negativeSquat_throws() {
        assertThrows(InvalidRequestException.class,
                () -> service.generatePlan(req(120, -10, 180)));
    }

    @Test
    void validation_zeroDeadlift_throws() {
        assertThrows(InvalidRequestException.class,
                () -> service.generatePlan(req(120, 150, 0)));
    }

    // ── helper ─────────────────────────────────────────────────────────────

    private WorkoutPlanRequest req(double bench, double squat, double deadlift) {
        return new WorkoutPlanRequest(bench, squat, deadlift);
    }
}
