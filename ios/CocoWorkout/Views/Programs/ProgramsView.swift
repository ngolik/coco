import SwiftUI

struct ProgramsView: View {
    private let programs: [FreeProgram] = [.svobodnaya]

    var body: some View {
        List {
            ForEach(programs) { program in
                Section(program.name) {
                    ForEach(program.days) { day in
                        NavigationLink(destination: ProgramDayView(day: day)) {
                            HStack {
                                Text(day.label)
                                Spacer()
                                Text("\(day.exercises.count) упражнений")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Программы")
    }
}

struct ProgramDayView: View {
    let day: FreeWorkoutDay

    @State private var showWorkout = false

    var body: some View {
        List(day.exercises) { exercise in
            HStack {
                Text(exercise.name)
                Spacer()
                Text("3 × —")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .navigationTitle(day.label)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Начать") {
                    showWorkout = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .fullScreenCover(isPresented: $showWorkout) {
            FreeWorkoutSessionView(day: day)
        }
    }
}
