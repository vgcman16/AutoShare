// Views/Components/VehicleRow.swift

import SwiftUI
import Kingfisher

struct VehicleRow: View {
    var vehicle: Vehicle

    var body: some View {
        HStack(spacing: 15) {
            // Safely unwrap vehicle.imageURL using nil-coalescing
            KFImage(URL(string: vehicle.imageURL ?? ""))
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
                Text("Location: \(vehicle.location ?? "Unknown")") // Safely unwrap vehicle.location if it's optional
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Previews

struct VehicleRow_Previews: PreviewProvider {
    static var previews: some View {
        let exampleVehicle = Vehicle(
            id: "vehicle123",
            make: "Toyota",
            model: "Camry",
            year: 2020,
            location: "New York",
            imageURL: "https://example.com/image.jpg",
            pricePerDay: 50.0,
            isAvailable: true,
            createdAt: Date()
        )
        VehicleRow(vehicle: exampleVehicle)
    }
}
