//
//  HomeView.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//


import SwiftUI

import SwiftUI

struct HomeTabsView: View {
    @StateObject var viewModel = RecipeViewModel()
    
    var body: some View {
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
        .onAppear {
            viewModel.fetchRecipes()
        }
    }
}

#Preview {
    return HomeTabsView()
}
