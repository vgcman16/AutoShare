//
//  SearchBar.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// Views/Components/SearchBar.swift

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search vehicles...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                )
                .accessibilityLabel("Search vehicles")
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}
