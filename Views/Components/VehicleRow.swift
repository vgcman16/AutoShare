//
//  VehicleRow.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// Views/Components/VehicleRow.swift

import SwiftUI
import Kingfisher

struct VehicleRow: View {
    var vehicle: Vehicle

    var body: some View {
        HStack(spacing: 15) {
            KFImage(URL(string: vehicle.imageURL))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                    .font(.headline)
                    .accessibilityLabel("Vehicle: \(vehicle.year) \(vehicle.make) \(vehicle.model)")
                Text("Price: $\(vehicle.pricePerDay, specifier: "%.2f")/day")
                    .font(.subheadline)
                Text("Location: \(vehicle.location)")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 5)
    }
}
