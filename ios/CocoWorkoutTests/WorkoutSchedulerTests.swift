import XCTest
@testable import CocoWorkout

final class WorkoutSchedulerTests: XCTestCase {
    // MARK: - Helpers

    private func makePlan(microcycles: [(id: Int, days: [Int])]) -> CachedPlan {
        let mcs: [Microcycle] = microcycles.map { mc in
            let days = mc.days.map { dayId in
                TrainingDay(id: dayId, label: "Day \(dayId)", exercises: [])
            }
            return Microcycle(id: mc.id, label: "MC \(mc.id)", days: days)
        }
        let data = try! JSONEncoder().encode(mcs)
        let plan = CachedPlan(rawJSON: String(data: data, encoding: .utf8)!)
        try! plan.decode()
        return plan
    }

    private func makeCompleted(microcycle: Int, day: Int) -> CompletedWorkout {
        try! CompletedWorkout(date: Date(), microcycle: microcycle, day: day, exerciseLogs: [])
    }

    // MARK: - Tests

    func testNextWorkoutWhenNoneCompleted() {
        let plan = makePlan(microcycles: [(1, [1, 2]), (2, [1, 2])])
        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: [])
        XCTAssertEqual(result?.microcycle, 1)
        XCTAssertEqual(result?.day, 1)
    }

    func testNextWorkoutSkipsCompleted() {
        let plan = makePlan(microcycles: [(1, [1, 2]), (2, [1])])
        let completed = [makeCompleted(microcycle: 1, day: 1)]
        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: completed)
        XCTAssertEqual(result?.microcycle, 1)
        XCTAssertEqual(result?.day, 2)
    }

    func testNextWorkoutAdvancesToNextMicrocycle() {
        let plan = makePlan(microcycles: [(1, [1]), (2, [1])])
        let completed = [makeCompleted(microcycle: 1, day: 1)]
        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: completed)
        XCTAssertEqual(result?.microcycle, 2)
        XCTAssertEqual(result?.day, 1)
    }

    func testNextWorkoutReturnsNilWhenAllDone() {
        let plan = makePlan(microcycles: [(1, [1, 2])])
        let completed = [
            makeCompleted(microcycle: 1, day: 1),
            makeCompleted(microcycle: 1, day: 2)
        ]
        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: completed)
        XCTAssertNil(result)
    }

    func testNextWorkoutEmptyPlan() {
        let plan = makePlan(microcycles: [])
        let result = WorkoutScheduler.nextWorkout(plan: plan, completed: [])
        XCTAssertNil(result)
    }
}
