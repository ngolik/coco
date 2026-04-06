import Foundation

actor WorkoutAPIClient {
    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

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

    enum APIError: LocalizedError {
        case badStatus(Int)

        var errorDescription: String? {
            switch self {
            case .badStatus(let code):
                return "Server returned status \(code)"
            }
        }
    }

    static func fromPlist() -> WorkoutAPIClient {
        let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
            ?? "http://localhost:8000"
        let url = URL(string: urlString) ?? URL(string: "http://localhost:8000")!
        return WorkoutAPIClient(baseURL: url)
    }
}
