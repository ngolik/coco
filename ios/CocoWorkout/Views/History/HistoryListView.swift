import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Query(sort: \CompletedWorkout.date, order: .reverse)
    private var history: [CompletedWorkout]

    @Query private var plans: [CachedPlan]

    var body: some View {
        Group {
            if history.isEmpty {
                ContentUnavailableView(
                    "No Workouts Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Completed workouts will appear here.")
                )
            } else {
                List(history) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutRowView(workout: workout, plan: plans.first)
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}

struct WorkoutRowView: View {
    let workout: CompletedWorkout
    let plan: CachedPlan?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                .font(.headline)
            Text(dayLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var dayLabel: String {
        if let plan = plan,
           let mc = decodedMicrocycles(plan).first(where: { $0.id == workout.microcycle }),
           let day = mc.days.first(where: { $0.id == workout.day }) {
            return "\(mc.label) · \(day.label)"
        }
        return "Microcycle \(workout.microcycle) Day \(workout.day)"
    }

    private func decodedMicrocycles(_ plan: CachedPlan) -> [Microcycle] {
        if !plan.microcycles.isEmpty { return plan.microcycles }
        try? plan.decode()
        return plan.microcycles
    }
}
