//
//  SettingsView.swift
//  Strands
//
//  Created by Shresth Kapoor on 06/06/25.
//


import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Dark Mode")
                Text("Context Queue Size")
            }
            .navigationTitle("Settings")
        }
    }
}