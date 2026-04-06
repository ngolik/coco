package com.nerw.weather.service;

import com.nerw.weather.exception.InvalidRequestException;
import com.nerw.weather.model.*;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Generates a 4-microcycle workout plan based on the IntenseBeginner program.
 *
 * Program structure extracted from IntenseBeginner.numbers ('1 в день' sheet).
 * Each microcycle = 1 training week with 3 days.
 *
 * Exercise 1RM ratios (verified against actual logged weights in the file):
 *   Жим лежа           → bench_press_1rm        (base)
 *   Присед             → squat_1rm               (base)
 *   Становая тяга      → deadlift_1rm            (base)
 *   Жим стоя           → bench × 0.60            (Упр sheet + back-calc)
 *   Жим средним хватом → bench × 0.90            (back-calc from file data)
 *   Бицепс стоя        → bench × 0.40            (back-calc from file data)
 *   Молотковые сгибания→ bench × (1/6) per db    (mult=2 dumbbell, back-calc)
 *   Жим без ног        → bench × 0.80            (back-calc from file data)
 *
 * Weight formula: ROUND(1rm × pct / 100 / 2.5) × 2.5
 */
@Service
public class WorkoutPlanService {

    // Internal program template types
    private record SetTemplate(int numSets, int reps, int pct) {}
    private record ExerciseTemplate(String name, List<SetTemplate> setGroups) {}
    private record DayTemplate(List<ExerciseTemplate> exercises) {}
    private record ProgramMicrocycle(List<DayTemplate> days) {}

    /**
     * Full 4-microcycle program, hardcoded from IntenseBeginner.numbers.
     * Sets are expressed as numSets × reps @ pct% of exercise 1RM.
     */
    private static final List<ProgramMicrocycle> PROGRAM = buildProgram();

    private static List<ProgramMicrocycle> buildProgram() {
        return List.of(
            // ── MICROCYCLE 1 ────────────────────────────────────────────────
            new ProgramMicrocycle(List.of(
                new DayTemplate(List.of(
                    ex("Жим лежа",           sg(1,4,50), sg(3,3,62), sg(3,2,74)),
                    ex("Присед",             sg(1,3,55), sg(2,2,65), sg(2,1,75), sg(2,1,83)),
                    ex("Жим лежа",           sg(1,4,55), sg(1,3,66), sg(3,2,75), sg(3,1,80)),
                    ex("Жим стоя",           sg(5,5,50)),
                    ex("Жим средним хватом", sg(5,5,60))
                )),
                new DayTemplate(List.of(
                    ex("Жим лежа",              sg(1,4,55), sg(1,3,66), sg(5,3,75)),
                    ex("Становая тяга",          sg(1,3,50), sg(1,2,61), sg(2,2,70), sg(2,2,78), sg(2,1,86)),
                    ex("Жим лежа",              sg(3,3,62), sg(3,2,75), sg(3,1,82)),
                    ex("Бицепс стоя",           sg(5,5,50)),
                    ex("Молотковые сгибания",   sg(5,5,50)),
                    ex("Жим без ног",           sg(5,5,62))
                )),
                new DayTemplate(List.of(
                    ex("Жим лежа",           sg(1,3,62), sg(3,2,70), sg(3,1,76), sg(3,1,80)),
                    ex("Присед",             sg(1,4,51), sg(3,3,62), sg(3,2,75)),
                    ex("Жим лежа",           sg(4,3,66), sg(4,1,75)),
                    ex("Жим стоя",           sg(1,4,50), sg(4,4,61)),
                    ex("Жим средним хватом", sg(4,4,50), sg(4,3,60))
                ))
            )),
            // ── MICROCYCLE 2 ────────────────────────────────────────────────
            new ProgramMicrocycle(List.of(
                new DayTemplate(List.of(
                    ex("Жим лежа",           sg(1,4,58), sg(1,3,66), sg(3,2,75), sg(3,1,82)),
                    ex("Присед",             sg(1,3,61), sg(2,2,72), sg(2,1,79), sg(2,1,86), sg(2,1,92)),
                    ex("Жим лежа",           sg(1,4,50), sg(3,3,62), sg(1,3,70), sg(1,3,78), sg(2,2,83)),
                    ex("Жим стоя",           sg(5,5,55)),
                    ex("Жим средним хватом", sg(4,4,65))
                )),
                new DayTemplate(List.of(
                    ex("Жим лежа",              sg(1,4,62), sg(4,4,70)),
                    ex("Становая тяга",          sg(3,3,61), sg(3,2,75)),
                    ex("Жим лежа",              sg(3,3,66), sg(3,1,78)),
                    ex("Бицепс стоя",           sg(5,5,60)),
                    ex("Молотковые сгибания",   sg(5,5,60)),
                    ex("Жим без ног",           sg(1,3,61), sg(4,2,72))
                )),
                new DayTemplate(List.of(
                    ex("Жим лежа",           sg(4,4,58), sg(4,3,66)),
                    ex("Присед",             sg(1,3,61), sg(2,2,72), sg(1,2,79), sg(1,2,85)),
                    ex("Жим лежа",           sg(3,3,62), sg(3,1,70)),
                    ex("Жим стоя",           sg(5,6,43)),
                    ex("Жим средним хватом", sg(3,3,60), sg(3,2,70))
                ))
            )),
            // ── MICROCYCLE 3 ────────────────────────────────────────────────
            new ProgramMicrocycle(List.of(
                new DayTemplate(List.of(
                    ex("Жим лежа",           sg(3,3,60), sg(3,1,72), sg(3,1,77)),
                    ex("Присед",             sg(1,3,63), sg(2,2,70), sg(2,1,77), sg(2,1,86)),
                    ex("Жим лежа",           sg(1,3,65), sg(2,2,76), sg(2,2,85), sg(2,2,88)),
                    ex("Жим стоя",           sg(5,6,40)),
                    ex("Жим средним хватом", sg(1,3,62), sg(2,2,75), sg(2,1,80), sg(2,1,85))
                )),
                new DayTemplate(List.of(
                    ex("Жим лежа",              sg(1,3,60), sg(2,2,72), sg(2,1,80), sg(2,1,85)),
                    ex("Становая тяга",          sg(1,4,51), sg(2,3,61), sg(2,2,70), sg(2,1,80), sg(2,1,88)),
                    ex("Жим лежа",              sg(3,3,65), sg(3,2,76), sg(3,1,81)),
                    ex("Бицепс стоя",           sg(5,5,50)),
                    ex("Молотковые сгибания",   sg(5,5,45)),
                    ex("Жим без ног",           sg(1,3,60), sg(5,2,75))
                )),
                // Day 3 is a rest/recovery day — no programmed sets
                new DayTemplate(List.of())
            )),
            // ── MICROCYCLE 4 ────────────────────────────────────────────────
            new ProgramMicrocycle(List.of(
                new DayTemplate(List.of(
                    ex("Жим лежа",           sg(3,3,66), sg(3,2,75)),
                    ex("Присед",             sg(1,3,65), sg(2,2,75), sg(2,1,85), sg(2,1,90)),
                    ex("Жим лежа",           sg(5,3,62)),
                    ex("Жим стоя",           sg(1,4,51), sg(4,4,60)),
                    ex("Жим средним хватом", sg(1,3,60), sg(5,3,70))
                )),
                new DayTemplate(List.of(
                    ex("Жим лежа",              sg(1,3,62), sg(2,2,75), sg(2,2,86)),
                    ex("Становая тяга",          sg(1,4,55), sg(3,3,65), sg(3,1,76)),
                    ex("Жим лежа",              sg(1,3,66), sg(2,2,78), sg(2,1,86), sg(2,1,90)),
                    ex("Бицепс стоя",           sg(5,5,50)),
                    ex("Молотковые сгибания",   sg(5,5,63)),
                    ex("Жим без ног",           sg(4,5,50))
                )),
                new DayTemplate(List.of(
                    ex("Жим лежа",           sg(3,3,62), sg(3,2,75), sg(3,1,83)),
                    ex("Присед",             sg(4,4,52)),
                    ex("Жим лежа",           sg(1,3,66), sg(2,2,75), sg(2,1,79)),
                    ex("Жим стоя",           sg(1,4,60), sg(4,4,69)),
                    ex("Жим средним хватом", sg(1,3,60), sg(5,3,70))
                ))
            ))
        );
    }

    private static ExerciseTemplate ex(String name, SetTemplate... groups) {
        return new ExerciseTemplate(name, List.of(groups));
    }

    private static SetTemplate sg(int numSets, int reps, int pct) {
        return new SetTemplate(numSets, reps, pct);
    }

    // ── 1RM resolution ──────────────────────────────────────────────────────

    /**
     * Returns the 1RM (kg) for the given exercise.
     * For dumbbell exercises (Молотковые сгибания), returns weight per dumbbell.
     */
    double exerciseOneRepMax(String name, double bench, double squat, double deadlift) {
        return switch (name) {
            case "Жим лежа"            -> bench;
            case "Присед"              -> squat;
            case "Становая тяга"       -> deadlift;
            case "Жим стоя"            -> bench * 0.60;
            case "Жим средним хватом"  -> bench * 0.90;
            case "Бицепс стоя"         -> bench * 0.40;
            case "Молотковые сгибания" -> bench / 6.0;  // per dumbbell
            case "Жим без ног"         -> bench * 0.80;
            default -> throw new InvalidRequestException("Unknown exercise: " + name);
        };
    }

    /**
     * Calculates working weight: ROUND(1rm × pct/100 / 2.5) × 2.5
     */
    double workingWeight(double oneRepMax, int pct) {
        return Math.round(oneRepMax * pct / 100.0 / 2.5) * 2.5;
    }

    // ── Public API ──────────────────────────────────────────────────────────

    public List<MicrocycleResponse> generatePlan(WorkoutPlanRequest request) {
        validateRequest(request);

        double bench    = request.benchPress1rm();
        double squat    = request.squat1rm();
        double deadlift = request.deadlift1rm();

        List<MicrocycleResponse> result = new ArrayList<>();
        int mcNumber = 1;
        for (ProgramMicrocycle mc : PROGRAM) {
            List<TrainingDay> days = new ArrayList<>();
            int dayNumber = 1;
            for (DayTemplate dt : mc.days()) {
                List<ExerciseDetail> exercises = new ArrayList<>();
                for (ExerciseTemplate et : dt.exercises()) {
                    double oneRm = exerciseOneRepMax(et.name(), bench, squat, deadlift);
                    List<SetDetail> sets = new ArrayList<>();
                    for (SetTemplate sg : et.setGroups()) {
                        double w = workingWeight(oneRm, sg.pct());
                        for (int i = 0; i < sg.numSets(); i++) {
                            sets.add(new SetDetail(sg.reps(), w));
                        }
                    }
                    exercises.add(new ExerciseDetail(et.name(), sets));
                }
                days.add(new TrainingDay(dayNumber++, exercises));
            }
            result.add(new MicrocycleResponse(mcNumber++, days));
        }
        return result;
    }

    private void validateRequest(WorkoutPlanRequest request) {
        if (request.benchPress1rm() <= 0) {
            throw new InvalidRequestException("bench_press_1rm must be positive");
        }
        if (request.squat1rm() <= 0) {
            throw new InvalidRequestException("squat_1rm must be positive");
        }
        if (request.deadlift1rm() <= 0) {
            throw new InvalidRequestException("deadlift_1rm must be positive");
        }
    }
}
