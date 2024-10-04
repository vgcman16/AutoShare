import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddVehicle = false
    
    var body: some View {
        NavigationView {
            List(firestoreService.vehicles) { vehicle in
                NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                    VStack(alignment: .leading) {
                        Text(vehicle.name)
                            .font(.headline)
                        Text(vehicle.model)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let rating = vehicle.averageRating {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", rating))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Vehicles")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        do {
                            try authViewModel.signOut()
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                    }) {
                        Text("Sign Out")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddVehicle = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Vehicle")
                }
            }
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView()
                    .environmentObject(firestoreService)
            }
        }
    }
}
