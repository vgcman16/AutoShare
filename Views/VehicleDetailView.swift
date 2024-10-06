// Views/VehicleDetailView.swift

import SwiftUI

struct VehicleDetailView: View {
    var vehicle: Vehicle
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var viewModel = VehicleDetailViewModel(vehicle: Vehicle.example, userService: UserService(), authViewModel: AuthViewModel())
    
    var body: some View {
        VStack {
            // Vehicle Details
            Text("Vehicle Details for \(vehicle.make) \(vehicle.model)")
                .font(.largeTitle)
            
            // Favorite Button
            Button(action: {
                viewModel.toggleFavorite(for: vehicle)
            }) {
                HStack {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite ? .red : .gray)
                    Text(viewModel.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.userService = userService
            viewModel.authViewModel = authViewModel
            viewModel.checkIfFavorite(for: vehicle)
        }
        .navigationTitle("Vehicle Details")
    }
}

struct VehicleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleDetailView(vehicle: Vehicle.example)
            .environmentObject(UserService())
            .environmentObject(AuthViewModel())
    }
}
