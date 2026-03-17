import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private let service: WeatherService

    init(service: WeatherService = WeatherService()) {
        self.service = service
    }

    func search() async {
        let city = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else {
            errorMessage = "Please enter a city name"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.fetchWeather(city: city)
            weather = result
            errorMessage = nil
        } catch {
            weather = nil
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
