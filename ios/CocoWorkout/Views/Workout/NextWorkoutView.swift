import SwiftUI
import SwiftData

struct NextWorkoutView: View {
    @Query private var plans: [CachedPlan]
    @Query private var completed: [CompletedWorkout]

    @State private var showActiveWorkout = false

    private var nextWorkoutInfo: (microcycle: Int, day: Int, trainingDay: TrainingDay)? {
        guard let plan = plans.first else { return nil }
        let microcycles = decodedMicrocycles(plan)
        guard !microcycles.isEmpty else { return nil }

        // Rebuild plan.microcycles if needed then use scheduler
        if plan.microcycles.isEmpty {
            try? plan.decode()
        }
        guard let next = WorkoutScheduler.nextWorkout(plan: plan, completed: completed) else {
            return nil
        }
        guard
            let mc = microcycles.first(where: { $0.id == next.microcycle }),
            let day = mc.days.first(where: { $0.id == next.day })
        else { return nil }
        return (next.microcycle, next.day, day)
    }

    var body: some View {
        Group {
            if plans.isEmpty {
                ContentUnavailableView(
                    "No Plan Yet",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Go to the Plan tab and fetch your workout plan first.")
                )
            } else if let info = nextWorkoutInfo {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Next Workout")
                            .font(.title2)
                            .bold()
                        Text("Microcycle \(info.microcycle) · \(info.trainingDay.label)")
                            .foregroundStyle(.secondary)
                    }

                    List(info.trainingDay.exercises) { exercise in
                        HStack {
                            Text(exercise.name)
                            Spacer()
                            Text("\(exercise.sets) × \(exercise.reps)")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .frame(maxHeight: 300)

                    Button("Start Workout") {
                        showActiveWorkout = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
                .fullScreenCover(isPresented: $showActiveWorkout) {
                    ActiveWorkoutView(
                        trainingDay: info.trainingDay,
                        microcycleIndex: info.microcycle,
                        dayIndex: info.day
                    )
                }
            } else {
                ContentUnavailableView(
                    "All Done!",
                    systemImage: "trophy.fill",
                    description: Text("You have completed all workouts in the current plan.")
                )
            }
        }
        .navigationTitle("Workout")
    }

    private func decodedMicrocycles(_ plan: CachedPlan) -> [Microcycle] {
        if !plan.microcycles.isEmpty { return plan.microcycles }
        try? plan.decode()
        return plan.microcycles
    }
}
