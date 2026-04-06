import Foundation

struct WorkoutAPIClient {
    let baseURL: URL

    func fetchPlan(_ request: WorkoutPlanRequest) async throws -> [Microcycle] {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent("/api/workout/plan"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        return try JSONDecoder().decode([Microcycle].self, from: data)
    }

    enum APIError: Error, LocalizedError {
        case badStatus(Int)

        var errorDescription: String? {
            switch self {
            case .badStatus(let code): return "Server returned status \(code)"
            }
        }
    }
}
