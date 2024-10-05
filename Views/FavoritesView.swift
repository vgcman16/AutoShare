import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.favoriteVehicles.isEmpty {
                    Text("No favorite vehicles yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.favoriteVehicles) { vehicle in
                        NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                            VehicleRow(vehicle: vehicle)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Favorites")
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}
