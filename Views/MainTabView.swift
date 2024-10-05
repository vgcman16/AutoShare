//
//  MainTabView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// Views/MainTabView.swift

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            VehicleListView()
                .tabItem {
                    Label("Vehicles", systemImage: "car.fill")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }

            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}
