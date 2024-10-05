//
//  VehicleListView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/4/24.
//


// VehicleListView.swift

import SwiftUI

struct VehicleListView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    
    var body: some View {
        VStack {
            if firestoreService.vehicles.isEmpty {
                Text("No vehicles available at the moment.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List(firestoreService.vehicles) { vehicle in
                    NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                        HStack(spacing: 15) {
                            AsyncImage(url: URL(string: vehicle.imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 80, height: 80)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(8)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                                    .font(.headline)
                                Text("Price: $\(vehicle.pricePerDay, specifier: "%.2f")/day")
                                    .font(.subheadline)
                                Text("Location: \(vehicle.location)")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Available Vehicles")
        .onAppear {
            firestoreService.fetchAvailableVehicles()
        }
    }
}
