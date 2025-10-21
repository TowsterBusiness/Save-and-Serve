//
//  ContentView.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RecipeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
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
                            .background(Color.white)
                            .shadow(color: .gray.opacity(0.15), radius: 3, y: 2)
                    
                    // 🧾 Main Tab View content below header
                    ZStack {
                        TabView {
                            RecipesListView(viewModel: viewModel)
                                .tabItem {
                                    Label("Recipes", systemImage: "list.bullet")
                                }
                            
                            HistoryView(viewModel: viewModel)
                                .tabItem {
                                    Label("Saved", systemImage: "bookmark.fill")
                                }
                        }
                    }
                    
                    
                }
                
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: CameraScreen(viewModel: viewModel)) {
                            Image(systemName: "camera")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20), style: .continuous))
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 70)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
