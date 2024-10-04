import SwiftUI
import FirebaseAuth

struct AddReviewView: View {
    var vehicle: Vehicle
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var rating: Int = 3
    @State private var comment: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    Picker("Rating", selection: $rating) {
                        ForEach(1...5, id: \.self) { number in
                            Text("\(number) Star\(number > 1 ? "s" : "")").tag(number)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Comment")) {
                    TextEditor(text: $comment)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Review")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Submit") {
                submitReview()
            })
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func submitReview() {
        guard !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a comment."
            showError = true
            return
        }
        
        guard let user = authViewModel.user else {
            errorMessage = "User not authenticated."
            showError = true
            return
        }
        
        let newReview = Review(
            vehicleID: vehicle.id ?? "",
            reviewerID: user.uid,
            rating: rating,
            comment: comment,
            timestamp: Date()
        )
        
        firestoreService.addReview(review: newReview) { result in
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
