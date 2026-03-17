import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    let onSearch: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Enter city name...", text: $searchText)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .foregroundColor(.white)
                .tint(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .onSubmit {
                    onSearch()
                }

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        SearchView(searchText: .constant("London"), onSearch: {})
    }
}
