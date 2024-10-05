//
//  FavoritesView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// Views/FavoritesView.swift

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationView {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            if viewModel.favoriteVehicles.isEmpty {
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
            .navigationTitle("My Favorites")
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}
