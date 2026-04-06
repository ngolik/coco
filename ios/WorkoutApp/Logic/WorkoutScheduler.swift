import Foundation

struct WorkoutScheduler {
    /// Returns the first (microcycle, day) pair from plan that has no
    /// corresponding CompletedWorkout, scanning in order: microcycle 1→4, day 1→N.
    static func nextWorkout(
        plan: CachedPlan,
        completed: [CompletedWorkout]
    ) -> (microcycle: Int, day: Int)? {
        let doneSet = Set(completed.map { "\($0.microcycle)-\($0.day)" })
        for mc in plan.microcycles {
            for day in mc.days {
                if !doneSet.contains("\(mc.id)-\(day.id)") {
                    return (mc.id, day.id)
                }
            }
        }
        return nil
    }
}
