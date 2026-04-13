import Foundation

// MARK: - Program template types (private)

private struct SetTemplate {
    let numSets: Int
    let reps: Int
    let pct: Int
}

private struct ExerciseTemplate {
    let name: String
    let setGroups: [SetTemplate]
}

private struct DayTemplate {
    let exercises: [ExerciseTemplate]
}

private struct MicrocycleTemplate {
    let days: [DayTemplate]
}

// MARK: - Helpers

private func sg(_ numSets: Int, _ reps: Int, _ pct: Int) -> SetTemplate {
    SetTemplate(numSets: numSets, reps: reps, pct: pct)
}

private func ex(_ name: String, _ groups: SetTemplate...) -> ExerciseTemplate {
    ExerciseTemplate(name: name, setGroups: groups)
}

// MARK: - 4-Microcycle Program
// Source: IntenseBeginner.numbers ('1 в день' sheet), ported from WorkoutPlanService.java

private let program: [MicrocycleTemplate] = [

    // ── MICROCYCLE 1 ──────────────────────────────────────────────────────
    MicrocycleTemplate(days: [
        DayTemplate(exercises: [
            ex("Жим лежа",           sg(1,4,50), sg(3,3,62), sg(3,2,74)),
            ex("Присед",             sg(1,3,55), sg(2,2,65), sg(2,1,75), sg(2,1,83)),
            ex("Жим лежа",           sg(1,4,55), sg(1,3,66), sg(3,2,75), sg(3,1,80)),
            ex("Жим стоя",           sg(5,5,50)),
            ex("Жим средним хватом", sg(5,5,60))
        ]),
        DayTemplate(exercises: [
            ex("Жим лежа",              sg(1,4,55), sg(1,3,66), sg(5,3,75)),
            ex("Становая тяга",          sg(1,3,50), sg(1,2,61), sg(2,2,70), sg(2,2,78), sg(2,1,86)),
            ex("Жим лежа",              sg(3,3,62), sg(3,2,75), sg(3,1,82)),
            ex("Бицепс стоя",           sg(5,5,50)),
            ex("Молотковые сгибания",   sg(5,5,50)),
            ex("Жим без ног",           sg(5,5,62))
        ]),
        DayTemplate(exercises: [
            ex("Жим лежа",           sg(1,3,62), sg(3,2,70), sg(3,1,76), sg(3,1,80)),
            ex("Присед",             sg(1,4,51), sg(3,3,62), sg(3,2,75)),
            ex("Жим лежа",           sg(4,3,66), sg(4,1,75)),
            ex("Жим стоя",           sg(1,4,50), sg(4,4,61)),
            ex("Жим средним хватом", sg(4,4,50), sg(4,3,60))
        ])
    ]),

    // ── MICROCYCLE 2 ──────────────────────────────────────────────────────
    MicrocycleTemplate(days: [
        DayTemplate(exercises: [
            ex("Жим лежа",           sg(1,4,58), sg(1,3,66), sg(3,2,75), sg(3,1,82)),
            ex("Присед",             sg(1,3,61), sg(2,2,72), sg(2,1,79), sg(2,1,86), sg(2,1,92)),
            ex("Жим лежа",           sg(1,4,50), sg(3,3,62), sg(1,3,70), sg(1,3,78), sg(2,2,83)),
            ex("Жим стоя",           sg(5,5,55)),
            ex("Жим средним хватом", sg(4,4,65))
        ]),
        DayTemplate(exercises: [
            ex("Жим лежа",              sg(1,4,62), sg(4,4,70)),
            ex("Становая тяга",          sg(3,3,61), sg(3,2,75)),
            ex("Жим лежа",              sg(3,3,66), sg(3,1,78)),
            ex("Бицепс стоя",           sg(5,5,60)),
            ex("Молотковые сгибания",   sg(5,5,60)),
            ex("Жим без ног",           sg(1,3,61), sg(4,2,72))
        ]),
        DayTemplate(exercises: [
            ex("Жим лежа",           sg(4,4,58), sg(4,3,66)),
            ex("Присед",             sg(1,3,61), sg(2,2,72), sg(1,2,79), sg(1,2,85)),
            ex("Жим лежа",           sg(3,3,62), sg(3,1,70)),
            ex("Жим стоя",           sg(5,6,43)),
            ex("Жим средним хватом", sg(3,3,60), sg(3,2,70))
        ])
    ]),

    // ── MICROCYCLE 3 ──────────────────────────────────────────────────────
    MicrocycleTemplate(days: [
        DayTemplate(exercises: [
            ex("Жим лежа",           sg(3,3,60), sg(3,1,72), sg(3,1,77)),
            ex("Присед",             sg(1,3,63), sg(2,2,70), sg(2,1,77), sg(2,1,86)),
            ex("Жим лежа",           sg(1,3,65), sg(2,2,76), sg(2,2,85), sg(2,2,88)),
            ex("Жим стоя",           sg(5,6,40)),
            ex("Жим средним хватом", sg(1,3,62), sg(2,2,75), sg(2,1,80), sg(2,1,85))
        ]),
        DayTemplate(exercises: [
            ex("Жим лежа",              sg(1,3,60), sg(2,2,72), sg(2,1,80), sg(2,1,85)),
            ex("Становая тяга",          sg(1,4,51), sg(2,3,61), sg(2,2,70), sg(2,1,80), sg(2,1,88)),
            ex("Жим лежа",              sg(3,3,65), sg(3,2,76), sg(3,1,81)),
            ex("Бицепс стоя",           sg(5,5,50)),
            ex("Молотковые сгибания",   sg(5,5,45)),
            ex("Жим без ног",           sg(1,3,60), sg(5,2,75))
        ]),
        // Day 3 is a rest/recovery day — no programmed sets
        DayTemplate(exercises: [])
    ]),

    // ── MICROCYCLE 4 ──────────────────────────────────────────────────────
    MicrocycleTemplate(days: [
        DayTemplate(exercises: [
            ex("Жим лежа",           sg(3,3,66), sg(3,2,75)),
            ex("Присед",             sg(1,3,65), sg(2,2,75), sg(2,1,85), sg(2,1,90)),
            ex("Жим лежа",           sg(5,3,62)),
            ex("Жим стоя",           sg(1,4,51), sg(4,4,60)),
            ex("Жим средним хватом", sg(1,3,60), sg(5,3,70))
        ]),
        DayTemplate(exercises: [
            ex("Жим лежа",              sg(1,3,62), sg(2,2,75), sg(2,2,86)),
            ex("Становая тяга",          sg(1,4,55), sg(3,3,65), sg(3,1,76)),
            ex("Жим лежа",              sg(1,3,66), sg(2,2,78), sg(2,1,86), sg(2,1,90)),
            ex("Бицепс стоя",           sg(5,5,50)),
            ex("Молотковые сгибания",   sg(5,5,63)),
            ex("Жим без ног",           sg(4,5,50))
        ]),
        DayTemplate(exercises: [
            ex("Жим лежа",           sg(3,3,62), sg(3,2,75), sg(3,1,83)),
            ex("Присед",             sg(4,4,52)),
            ex("Жим лежа",           sg(1,3,66), sg(2,2,75), sg(2,1,79)),
            ex("Жим стоя",           sg(1,4,60), sg(4,4,69)),
            ex("Жим средним хватом", sg(1,3,60), sg(5,3,70))
        ])
    ])
]

// MARK: - WorkoutPlanGenerator

/// Generates a full 4-microcycle workout plan locally — no network required.
enum WorkoutPlanGenerator {

    /// Returns the exercise-specific 1RM (kg).
    /// For "Молотковые сгибания" this is weight per dumbbell (bench / 6).
    static func exerciseOneRepMax(name: String, bench: Double, squat: Double, deadlift: Double) -> Double {
        switch name {
        case "Жим лежа":            return bench
        case "Присед":              return squat
        case "Становая тяга":       return deadlift
        case "Жим стоя":            return bench * 0.60
        case "Жим средним хватом":  return bench * 0.90
        case "Бицепс стоя":         return bench * 0.40
        case "Молотковые сгибания": return bench / 6.0   // per dumbbell
        case "Жим без ног":         return bench * 0.80
        default:                    return bench          // fallback
        }
    }

    /// Working weight formula: ROUND(1rm × pct/100 / 2.5) × 2.5
    static func workingWeight(oneRepMax: Double, pct: Int) -> Double {
        (oneRepMax * Double(pct) / 100.0 / 2.5).rounded() * 2.5
    }

    /// Generates all 4 microcycles for the given 1RM values.
    static func generate(bench: Double, squat: Double, deadlift: Double) -> [Microcycle] {
        program.enumerated().map { mcIndex, mc in
            let days: [TrainingDay] = mc.days.enumerated().map { dayIndex, dt in
                let exercises: [Exercise] = dt.exercises.map { et in
                    let oneRM = exerciseOneRepMax(name: et.name, bench: bench, squat: squat, deadlift: deadlift)
                    let sets: [WorkoutSet] = et.setGroups.flatMap { sg in
                        (0 ..< sg.numSets).map { _ in
                            WorkoutSet(weightKg: workingWeight(oneRepMax: oneRM, pct: sg.pct), reps: sg.reps)
                        }
                    }
                    return Exercise(name: et.name, sets: sets)
                }
                return TrainingDay(day: dayIndex + 1, exercises: exercises)
            }
            return Microcycle(microcycle: mcIndex + 1, days: days)
        }
    }
}
