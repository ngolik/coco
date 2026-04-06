import XCTest
@testable import WorkoutApp

final class WorkoutSchedulerTests: XCTestCase {

    func testNextWorkout_returnsFirstDayWhenNoneCompleted() throws {
        let mc1 = Microcycle(id: 1, label: "MC1", days: [
            TrainingDay(id: 1, label: "Day 1", exercises: []),
            TrainingDay(id: 2, label: "Day 2", exercises: []),
        ])
        let mc2 = Microcycle(id: 2, label: "MC2", days: [
            TrainingDay(id: 1, label: "Day 1", exercises: []),
        ])
        let plan = CachedPlan(rawJSON: "[]")
        plan.microcycles = [mc1, mc2]

        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: [])
        XCTAssertEqual(result?.microcycle, 1)
        XCTAssertEqual(result?.day, 1)
    }

    func testNextWorkout_skipsCompletedDays() throws {
        let mc1 = Microcycle(id: 1, label: "MC1", days: [
            TrainingDay(id: 1, label: "Day 1", exercises: []),
            TrainingDay(id: 2, label: "Day 2", exercises: []),
        ])
        let plan = CachedPlan(rawJSON: "[]")
        plan.microcycles = [mc1]

        let done = try CompletedWorkout(date: Date(), microcycle: 1, day: 1, exerciseLogs: [])
        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: [done])
        XCTAssertEqual(result?.microcycle, 1)
        XCTAssertEqual(result?.day, 2)
    }

    func testNextWorkout_advancesToNextMicrocycle() throws {
        let mc1 = Microcycle(id: 1, label: "MC1", days: [
            TrainingDay(id: 1, label: "Day 1", exercises: []),
        ])
        let mc2 = Microcycle(id: 2, label: "MC2", days: [
            TrainingDay(id: 1, label: "Day 1", exercises: []),
        ])
        let plan = CachedPlan(rawJSON: "[]")
        plan.microcycles = [mc1, mc2]

        let done = try CompletedWorkout(date: Date(), microcycle: 1, day: 1, exerciseLogs: [])
        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: [done])
        XCTAssertEqual(result?.microcycle, 2)
        XCTAssertEqual(result?.day, 1)
    }

    func testNextWorkout_returnsNilWhenAllCompleted() throws {
        let mc1 = Microcycle(id: 1, label: "MC1", days: [
            TrainingDay(id: 1, label: "Day 1", exercises: []),
        ])
        let plan = CachedPlan(rawJSON: "[]")
        plan.microcycles = [mc1]

        let done = try CompletedWorkout(date: Date(), microcycle: 1, day: 1, exerciseLogs: [])
        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: [done])
        XCTAssertNil(result)
    }
}
