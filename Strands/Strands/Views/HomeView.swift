//
//  HomeView.swift
//  Strands
//
//  Created by Shresth Kapoor on 06/06/25.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Strands 👋")
                    .font(.title)
                    .padding()
                Text("Think deeper. Chat smarter.")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Home")
        }
    }
}
