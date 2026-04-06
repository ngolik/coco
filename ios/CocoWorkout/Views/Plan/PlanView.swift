import SwiftUI
import SwiftData

@Observable
final class PlanViewModel {
    var bench: String = ""
    var squat: String = ""
    var deadlift: String = ""
    var isLoading = false
    var errorMessage: String?

    private let apiClient = WorkoutAPIClient.fromPlist()

    func fetchPlan(context: ModelContext) async {
        guard
            let b = Double(bench), b > 0,
            let s = Double(squat), s > 0,
            let d = Double(deadlift), d > 0
        else {
            errorMessage = "Enter valid positive values for all three lifts."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let request = WorkoutPlanRequest(benchPress1RM: b, squat1RM: s, deadlift1RM: d)
            let microcycles = try await apiClient.fetchPlan(request)
            let encoder = JSONEncoder()
            let data = try encoder.encode(microcycles)
            let rawJSON = String(data: data, encoding: .utf8) ?? "[]"

            // Delete previous cached plans
            try context.delete(model: CachedPlan.self)

            let plan = CachedPlan(rawJSON: rawJSON)
            try plan.decode()
            context.insert(plan)

            // Upsert user profile
            let profiles = try context.fetch(FetchDescriptor<UserProfile>())
            if let profile = profiles.first {
                profile.benchPress1RM = b
                profile.squat1RM = s
                profile.deadlift1RM = d
                profile.updatedAt = Date()
            } else {
                context.insert(UserProfile(benchPress1RM: b, squat1RM: s, deadlift1RM: d))
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct PlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plans: [CachedPlan]
    @Query private var completed: [CompletedWorkout]
    @Query private var profiles: [UserProfile]

    @State private var viewModel = PlanViewModel()
    @State private var showError = false

    private var currentPlan: CachedPlan? { plans.first }

    var body: some View {
        List {
            Section("Your 1-Rep Maxes (kg)") {
                TextField("Bench Press", text: $viewModel.bench)
                    .keyboardType(.decimalPad)
                TextField("Squat", text: $viewModel.squat)
                    .keyboardType(.decimalPad)
                TextField("Deadlift", text: $viewModel.deadlift)
                    .keyboardType(.decimalPad)

                Button(action: fetchPlan) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Fetch Plan")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isLoading)
            }

            if let plan = currentPlan {
                let microcycles = decodedMicrocycles(plan)
                ForEach(microcycles) { mc in
                    NavigationLink(destination: MicrocycleDetailView(microcycle: mc, completed: completed)) {
                        HStack {
                            Text(mc.label)
                            Spacer()
                            let doneCount = mc.days.filter { day in
                                completed.contains { $0.microcycle == mc.id && $0.day == day.id }
                            }.count
                            Text("\(doneCount)/\(mc.days.count)")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle("Training Plan")
        .onAppear { prefillFromProfile() }
        .alert("Error", isPresented: $showError, presenting: viewModel.errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { msg in
            Text(msg)
        }
        .onChange(of: viewModel.errorMessage) { _, new in
            showError = new != nil
        }
    }

    private func decodedMicrocycles(_ plan: CachedPlan) -> [Microcycle] {
        if !plan.microcycles.isEmpty { return plan.microcycles }
        try? plan.decode()
        return plan.microcycles
    }

    private func fetchPlan() {
        Task { await viewModel.fetchPlan(context: modelContext) }
    }

    private func prefillFromProfile() {
        guard let profile = profiles.first else { return }
        if viewModel.bench.isEmpty { viewModel.bench = String(profile.benchPress1RM) }
        if viewModel.squat.isEmpty { viewModel.squat = String(profile.squat1RM) }
        if viewModel.deadlift.isEmpty { viewModel.deadlift = String(profile.deadlift1RM) }
    }
}
