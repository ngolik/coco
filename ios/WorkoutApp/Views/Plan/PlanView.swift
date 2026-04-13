import SwiftUI
import SwiftData

struct PlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var plans: [CachedPlan]
    @Query private var completedWorkouts: [CompletedWorkout]

    @State private var bench = ""
    @State private var squat = ""
    @State private var deadlift = ""
    @State private var errorMessage: String?
    @State private var microcycles: [Microcycle] = []


    var body: some View {
        List {
            rmSection
            if let error = errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }
            planSection
        }
        .navigationTitle("Training Plan")
        .onAppear(perform: loadStoredData)
    }

    // MARK: - Sections

    private var rmSection: some View {
        Section("1RM Values (kg)") {
            labeledField("Bench Press", placeholder: "115", text: $bench)
            labeledField("Squat",       placeholder: "80",  text: $squat)
            labeledField("Deadlift",    placeholder: "140", text: $deadlift)
            Button(action: fetchPlan) {
                Text("Generate Plan").frame(maxWidth: .infinity)
            }
            .disabled(bench.isEmpty || squat.isEmpty || deadlift.isEmpty)
        }
    }

    @ViewBuilder
    private var planSection: some View {
        let doneSet = Set(completedWorkouts.map { "\($0.microcycle)-\($0.day)" })
        ForEach(microcycles) { mc in
            let done = mc.days.filter { doneSet.contains("\(mc.id)-\($0.id)") }.count
            Section {
                NavigationLink {
                    MicrocycleDetailView(microcycle: mc, doneSet: doneSet)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mc.label)
                            Text("\(done)/\(mc.days.count) days completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if done == mc.days.count {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
            } header: {
                Text(mc.label)
            }
        }
    }

    private func labeledField(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(placeholder, text: text)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
        }
    }

    // MARK: - Logic

    private func loadStoredData() {
        if let profile = profiles.first {
            bench    = String(profile.benchPress1RM)
            squat    = String(profile.squat1RM)
            deadlift = String(profile.deadlift1RM)
        }
        if let last = plans.last, last.microcycles.isEmpty {
            try? last.decode()
            microcycles = last.microcycles
        } else if let last = plans.last {
            microcycles = last.microcycles
        }
    }

    private func fetchPlan() {
        guard let b = Double(bench),
              let s = Double(squat),
              let d = Double(deadlift) else {
            errorMessage = "Please enter valid numbers."
            return
        }
        errorMessage = nil

        if let existing = profiles.first {
            existing.benchPress1RM = b
            existing.squat1RM = s
            existing.deadlift1RM = d
            existing.updatedAt = Date()
        } else {
            modelContext.insert(UserProfile(benchPress1RM: b, squat1RM: s, deadlift1RM: d))
        }

        let result = WorkoutPlanGenerator.generate(bench: b, squat: s, deadlift: d)
        let json = (try? JSONEncoder().encode(result)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        for old in plans { modelContext.delete(old) }
        let plan = CachedPlan(rawJSON: json)
        modelContext.insert(plan)
        microcycles = result
    }
}
