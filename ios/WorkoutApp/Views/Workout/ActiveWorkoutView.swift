import SwiftUI
import SwiftData
import Combine

struct ActiveWorkoutView: View {
    let day: TrainingDay
    let microcycleIndex: Int
    let dayIndex: Int

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var setCompletion: [[Bool]] = []
    @State private var restTimeRemaining: Int = 0
    @State private var restTimerLabel: String = ""
    @State private var timerCancellable: AnyCancellable?

    private var allSetsCompleted: Bool {
        !setCompletion.isEmpty && setCompletion.allSatisfy { $0.allSatisfy { $0 } }
    }

    var body: some View {
        List {
            ForEach(Array(day.exercises.enumerated()), id: \.offset) { idx, exercise in
                Section {
                    ForEach(Array(exercise.sets.enumerated()), id: \.offset) { setIdx, set in
                        if idx < setCompletion.count, setIdx < setCompletion[idx].count {
                            Button {
                                toggleSet(
                                    exerciseIdx: idx,
                                    setIdx: setIdx,
                                    restSeconds: 90,
                                    exerciseName: exercise.name
                                )
                            } label: {
                                HStack {
                                    Image(
                                        systemName: setCompletion[idx][setIdx]
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                    )
                                    .foregroundStyle(setCompletion[idx][setIdx] ? .green : .secondary)
                                    .font(.title3)
                                    Text("Set \(setIdx + 1): \(set.reps) reps × \(String(format: "%.1f", set.weightKg)) kg")
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text(exercise.name)
                }
            }

            if restTimeRemaining > 0 {
                Section {
                    HStack {
                        Image(systemName: "timer")
                        Text("\(restTimeRemaining)s remaining")
                            .font(.title2.monospacedDigit())
                            .foregroundStyle(.orange)
                        Spacer()
                        Button("Skip") { stopTimer() }
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Rest — \(restTimerLabel)")
                }
            }

            Section {
                Button(action: finishWorkout) {
                    Text("Finish Workout")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(allSetsCompleted ? .white : .secondary)
                }
                .listRowBackground(allSetsCompleted ? Color.blue : Color(.systemGray5))
                .disabled(!allSetsCompleted)
            }
        }
        .navigationTitle(day.label)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setCompletion = day.exercises.map { Array(repeating: false, count: $0.sets.count) }
        }
        .onDisappear { stopTimer() }
    }

    // MARK: - Timer

    private func toggleSet(exerciseIdx: Int, setIdx: Int, restSeconds: Int, exerciseName: String) {
        guard exerciseIdx < setCompletion.count,
              setIdx < setCompletion[exerciseIdx].count else { return }
        setCompletion[exerciseIdx][setIdx].toggle()
        if setCompletion[exerciseIdx][setIdx] {
            startTimer(seconds: restSeconds, label: exerciseName)
        } else {
            stopTimer()
        }
    }

    private func startTimer(seconds: Int, label: String) {
        stopTimer()
        restTimeRemaining = seconds
        restTimerLabel = label
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if restTimeRemaining > 0 {
                    restTimeRemaining -= 1
                } else {
                    stopTimer()
                }
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        restTimeRemaining = 0
        restTimerLabel = ""
    }

    // MARK: - Finish

    private func finishWorkout() {
        let logs = day.exercises.enumerated().map { idx, exercise in
            ExerciseLog(
                exerciseName: exercise.name,
                sets: idx < setCompletion.count ? setCompletion[idx] : []
            )
        }
        if let workout = try? CompletedWorkout(
            date: Date(),
            microcycle: microcycleIndex,
            day: dayIndex,
            exerciseLogs: logs
        ) {
            modelContext.insert(workout)
        }
        dismiss()
    }
}
