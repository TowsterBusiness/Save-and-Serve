//
//  ContentView.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Open Camera", destination: CameraScreen())
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
