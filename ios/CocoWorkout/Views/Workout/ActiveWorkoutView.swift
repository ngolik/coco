import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    let trainingDay: TrainingDay
    let microcycleIndex: Int
    let dayIndex: Int

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var setStates: [[Bool]] = []
    @State private var timerRemaining: Int = 0
    @State private var timerActive = false
    @State private var errorMessage: String?
    @State private var showError = false

    private let restDuration = 90

    private var allSetsDone: Bool {
        setStates.allSatisfy { $0.allSatisfy { $0 } }
    }

    var body: some View {
        NavigationStack {
            List {
                if timerActive {
                    Section {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.orange)
                            Text("Rest: \(timerRemaining)s")
                                .font(.headline)
                                .monospacedDigit()
                            Spacer()
                            Button("Skip") { stopTimer() }
                                .buttonStyle(.borderless)
                        }
                    }
                }

                ForEach(Array(trainingDay.exercises.enumerated()), id: \.offset) { index, exercise in
                    Section(exercise.name) {
                        ForEach(0..<exercise.sets, id: \.self) { setIndex in
                            Button(action: { toggleSet(exerciseIndex: index, setIndex: setIndex) }) {
                                HStack {
                                    Image(systemName: setStates[safe: index]?[safe: setIndex] == true
                                        ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(setStates[safe: index]?[safe: setIndex] == true
                                        ? .green : .secondary)
                                    Text("Set \(setIndex + 1) — \(exercise.reps) reps @ \(formattedIntensity(exercise.intensityPct))")
                                        .foregroundStyle(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle(trainingDay.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Finish") { finishWorkout() }
                        .disabled(!allSetsDone)
                }
            }
            .onAppear { initSetStates() }
            .alert("Error", isPresented: $showError, presenting: errorMessage) { _ in
                Button("OK", role: .cancel) {}
            } message: { msg in
                Text(msg)
            }
        }
    }

    private func initSetStates() {
        setStates = trainingDay.exercises.map { Array(repeating: false, count: $0.sets) }
    }

    private func toggleSet(exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < setStates.count, setIndex < setStates[exerciseIndex].count else { return }
        setStates[exerciseIndex][setIndex].toggle()
        // Start rest timer when a set is checked
        if setStates[exerciseIndex][setIndex] {
            let exerciseDone = setStates[exerciseIndex].allSatisfy { $0 }
            if !exerciseDone {
                startTimer()
            }
        }
    }

    private func startTimer() {
        timerRemaining = restDuration
        timerActive = true
        Task {
            while timerRemaining > 0 && timerActive {
                try? await Task.sleep(for: .seconds(1))
                if timerActive {
                    timerRemaining -= 1
                }
            }
            timerActive = false
        }
    }

    private func stopTimer() {
        timerActive = false
        timerRemaining = 0
    }

    private func finishWorkout() {
        guard allSetsDone else { return }
        let logs = trainingDay.exercises.enumerated().map { index, exercise in
            ExerciseLog(
                exerciseName: exercise.name,
                sets: setStates[safe: index] ?? Array(repeating: false, count: exercise.sets)
            )
        }
        do {
            let workout = try CompletedWorkout(
                date: Date(),
                microcycle: microcycleIndex,
                day: dayIndex,
                exerciseLogs: logs
            )
            modelContext.insert(workout)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func formattedIntensity(_ pct: Double) -> String {
        String(format: "%.0f%%", pct * 100)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
