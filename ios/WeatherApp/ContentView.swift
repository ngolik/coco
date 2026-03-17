import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Weather App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                SearchView(searchText: $viewModel.searchText) {
                    Task { await viewModel.search() }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding()
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                if let weather = viewModel.weather {
                    WeatherCardView(weather: weather)
                        .transition(.opacity.combined(with: .scale))
                }

                Spacer()
            }
            .padding()
        }
        .animation(.easeInOut, value: viewModel.weather == nil)
        .animation(.easeInOut, value: viewModel.isLoading)
        .animation(.easeInOut, value: viewModel.errorMessage)
    }

    private var backgroundGradient: LinearGradient {
        guard let weather = viewModel.weather else {
            return LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return WeatherCardView.gradient(for: weather.iconCode)
    }
}

#Preview {
    ContentView()
}
