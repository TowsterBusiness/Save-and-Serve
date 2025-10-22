//
//  ContentView.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RecipeViewModel()
    @State private var showCamera = false
    
    var body: some View {
        NavigationStack { // Only one navigation stack
            VStack(spacing: 0) {
                
                // 🧠 Custom Header
                VStack(spacing: 4) {
                    Text("Save Your Fridge")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.accentColor)
                        .padding(.top, 10)
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.accentColor.opacity(0.8))
                        .cornerRadius(1)
                        .padding(.horizontal, 70)
                }
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.15), radius: 3, y: 2)
                
                // 🧾 Main Tab View content below header
                TabView {
                    RecipesListView(viewModel: viewModel)
                        .tabItem {
                            Label("Recipes", systemImage: "list.bullet")
                        }

                    HistoryView(viewModel: viewModel)
                        .tabItem {
                            Label("Saved", systemImage: "bookmark.fill")
                        }

                    IngredientsView(viewModel: viewModel)
                        .tabItem {
                            Label("Ingredients", systemImage: "leaf.fill")
                        }
                }

            }
            // Floating camera button as sheet
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showCamera = true }) {
                            Image(systemName: "camera")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20), style: .continuous))
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 70)
                        .sheet(isPresented: $showCamera) {
                            CameraScreen(viewModel: viewModel)
                        }
                    }
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
