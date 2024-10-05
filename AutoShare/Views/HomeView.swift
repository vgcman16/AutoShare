// HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var firestoreService: FirestoreService
    @State private var showingAddVehicle = false
    @State private var showingBookings = false
    @State private var showingTransactions = false
    @State private var showingUserProfile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to AutoShare!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                Spacer()
                
                NavigationLink(destination: VehicleListView()) {
                    Text("Browse Vehicles")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: TransactionListView()) {
                    Text("View Transactions")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Button(action: {
                    showingAddVehicle = true
                }) {
                    Text("List Your Vehicle")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showingAddVehicle) {
                    AddVehicleView()
                        .environmentObject(firestoreService)
                        .environmentObject(authViewModel)
                }
                
                NavigationLink(destination: BookingListView()) {
                    Text("My Bookings")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(FirestoreService())
    }
}
