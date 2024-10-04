import SwiftUI

struct AddVehicleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firestoreService: FirestoreService
    
    @State private var name: String = ""
    @State private var model: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vehicle Information")) {
                    TextField("Name", text: $name)
                    TextField("Model", text: $model)
                }
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Vehicle")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                addVehicle()
            })
        }
    }
    
    func addVehicle() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !model.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields."
            showError = true
            return
        }
        
        let newVehicle = Vehicle(name: name, model: model, averageRating: nil)
        firestoreService.addVehicle(vehicle: newVehicle) { result in
            switch result {
            case .success():
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
