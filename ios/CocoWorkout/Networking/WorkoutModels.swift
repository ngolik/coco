import Foundation

struct WorkoutPlanRequest: Encodable {
    let benchPress1RM: Double
    let squat1RM: Double
    let deadlift1RM: Double

    enum CodingKeys: String, CodingKey {
        case benchPress1RM = "bench_press_1rm"
        case squat1RM      = "squat_1rm"
        case deadlift1RM   = "deadlift_1rm"
    }
}

struct Microcycle: Codable, Identifiable {
    let id: Int
    let label: String
    let days: [TrainingDay]
}

struct TrainingDay: Codable, Identifiable {
    let id: Int
    let label: String
    let exercises: [Exercise]
}

struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let sets: Int
    let reps: String
    let intensityPct: Double

    enum CodingKeys: String, CodingKey {
        case id, name, sets, reps
        case intensityPct = "intensity_pct"
    }
}
