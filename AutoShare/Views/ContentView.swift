// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            if authViewModel.isLoggedIn {
                HomeView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            // Optionally fetch additional data if needed
        }
    }
}
