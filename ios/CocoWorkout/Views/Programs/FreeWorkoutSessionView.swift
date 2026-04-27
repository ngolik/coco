import SwiftUI

struct FreeWorkoutSet: Identifiable {
    let id: UUID
    var reps: Int
    var isDone: Bool

    init(reps: Int = 10) {
        self.id = UUID()
        self.reps = reps
        self.isDone = false
    }
}

struct FreeWorkoutSessionView: View {
    let day: FreeWorkoutDay

    @Environment(\.dismiss) private var dismiss

    @State private var exerciseSets: [[FreeWorkoutSet]] = []
    @State private var timerRemaining: Int = 0
    @State private var timerActive = false

    private let restDuration = 90
    private let defaultSetsCount = 3
    private let defaultReps = 10

    private var allSetsDone: Bool {
        exerciseSets.allSatisfy { $0.allSatisfy { $0.isDone } }
    }

    var body: some View {
        NavigationStack {
            List {
                if timerActive {
                    Section {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.orange)
                            Text("Отдых: \(timerRemaining)с")
                                .font(.headline)
                                .monospacedDigit()
                            Spacer()
                            Button("Пропустить") { stopTimer() }
                                .buttonStyle(.borderless)
                        }
                    }
                }

                ForEach(Array(day.exercises.enumerated()), id: \.offset) { exIndex, exercise in
                    Section(exercise.name) {
                        let sets = exIndex < exerciseSets.count ? exerciseSets[exIndex] : []
                        ForEach(Array(sets.enumerated()), id: \.element.id) { setIndex, workoutSet in
                            HStack {
                                Button {
                                    toggleSet(exIndex: exIndex, setIndex: setIndex)
                                } label: {
                                    Image(
                                        systemName: exerciseSets[exIndex][setIndex].isDone
                                            ? "checkmark.circle.fill" : "circle"
                                    )
                                    .foregroundStyle(
                                        exerciseSets[exIndex][setIndex].isDone ? .green : .secondary
                                    )
                                }
                                .buttonStyle(.plain)

                                Text("Подход \(setIndex + 1)")
                                    .foregroundStyle(.primary)

                                Spacer()

                                Stepper(
                                    value: Binding(
                                        get: {
                                            exIndex < exerciseSets.count && setIndex < exerciseSets[exIndex].count
                                                ? exerciseSets[exIndex][setIndex].reps : defaultReps
                                        },
                                        set: { newValue in
                                            if exIndex < exerciseSets.count && setIndex < exerciseSets[exIndex].count {
                                                exerciseSets[exIndex][setIndex].reps = newValue
                                            }
                                        }
                                    ),
                                    in: 1...100
                                ) {
                                    Text("\(exerciseSets[exIndex][setIndex].reps) повт.")
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                        .frame(minWidth: 64, alignment: .trailing)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            deleteSet(exIndex: exIndex, indexSet: indexSet)
                        }

                        Button {
                            addSet(exIndex: exIndex)
                        } label: {
                            Label("Добавить подход", systemImage: "plus.circle")
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle(day.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Завершить") { dismiss() }
                        .disabled(!allSetsDone)
                }
            }
            .onAppear { initSets() }
        }
    }

    private func initSets() {
        exerciseSets = day.exercises.map { _ in
            (0..<defaultSetsCount).map { _ in FreeWorkoutSet(reps: defaultReps) }
        }
    }

    private func toggleSet(exIndex: Int, setIndex: Int) {
        guard exIndex < exerciseSets.count, setIndex < exerciseSets[exIndex].count else { return }
        exerciseSets[exIndex][setIndex].isDone.toggle()
        if exerciseSets[exIndex][setIndex].isDone {
            startTimer()
        }
    }

    private func addSet(exIndex: Int) {
        guard exIndex < exerciseSets.count else { return }
        exerciseSets[exIndex].append(FreeWorkoutSet(reps: defaultReps))
    }

    private func deleteSet(exIndex: Int, indexSet: IndexSet) {
        guard exIndex < exerciseSets.count, exerciseSets[exIndex].count > 1 else { return }
        exerciseSets[exIndex].remove(atOffsets: indexSet)
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
}
