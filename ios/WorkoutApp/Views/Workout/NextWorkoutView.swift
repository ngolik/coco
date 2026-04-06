import SwiftUI
import SwiftData

struct NextWorkoutView: View {
    @Query private var plans: [CachedPlan]
    @Query private var completedWorkouts: [CompletedWorkout]

    @State private var nextMicrocycle: Microcycle?
    @State private var nextDay: TrainingDay?

    var body: some View {
        Group {
            if let mc = nextMicrocycle, let day = nextDay {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(mc.label).font(.headline)
                            Text(day.label).foregroundStyle(.secondary)
                            Text("\(day.exercises.count) exercises")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Next Workout")
                    }

                    Section {
                        NavigationLink {
                            ActiveWorkoutView(
                                day: day,
                                microcycleIndex: mc.id,
                                dayIndex: day.id
                            )
                        } label: {
                            Text("Start Workout")
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            } else if plans.isEmpty {
                ContentUnavailableView(
                    "No Plan Yet",
                    systemImage: "clipboard",
                    description: Text("Go to Plan tab and fetch your training plan.")
                )
            } else {
                ContentUnavailableView(
                    "All Done!",
                    systemImage: "checkmark.seal.fill",
                    description: Text("You've completed all workouts in your current plan.")
                )
            }
        }
        .navigationTitle("Workout")
        .onAppear(perform: resolveNext)
        .onChange(of: completedWorkouts.count) {
            resolveNext()
        }
    }

    private func resolveNext() {
        guard let plan = plans.last else { return }
        if plan.microcycles.isEmpty { try? plan.decode() }
        guard let next = WorkoutScheduler.nextWorkout(plan: plan, completed: completedWorkouts) else {
            nextMicrocycle = nil
            nextDay = nil
            return
        }
        nextMicrocycle = plan.microcycles.first { $0.id == next.microcycle }
        nextDay = nextMicrocycle?.days.first { $0.id == next.day }
    }
}
