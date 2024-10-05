// Views/VehicleListView.swift

import SwiftUI

struct VehicleListView: View {
    @StateObject private var viewModel = VehicleListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                List(viewModel.filteredVehicles) { vehicle in
                    NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                        VehicleRow(vehicle: vehicle)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    viewModel.fetchVehicles()
                }
            }
            .navigationTitle("Available Vehicles")
            .onAppear {
                viewModel.fetchVehicles()
            }
        }
    }
}
