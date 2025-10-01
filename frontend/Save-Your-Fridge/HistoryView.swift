//
//  HistoryView.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//


import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: RecipeViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.savedRecipes.isEmpty {
                Text("No saved recipes yet.")
                    .foregroundColor(.gray)
                    .italic()
                    .navigationTitle("Saved Recipes")
            } else {
                List(viewModel.savedRecipes, id: \.GeneralInfo.id) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                        HStack {
                            AsyncImage(url: URL(string: recipe.GeneralInfo.image)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipped()
                            } placeholder: {
                                Color.gray
                                    .frame(width: 80, height: 80)
                            }
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading) {
                                Text(recipe.GeneralInfo.title)
                                    .font(.headline)
                                Text("\(recipe.GeneralInfo.usedIngredients.count) ingredients")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationTitle("Saved Recipes")
            }
        }
    }
}
