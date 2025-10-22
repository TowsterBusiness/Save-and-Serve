//
//  RecipesListView.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//

import SwiftUI

struct RecipesListView: View {
    @ObservedObject var viewModel: RecipeViewModel
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Fetch Recipes Button
                Button(action: {
                    fetchRecipes()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "fork.knife.circle.fill")
                            Text("Get Recipes")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                // MARK: - Recipes List
                List(viewModel.recipes, id: \.GeneralInfo.id) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                        HStack {
                            AsyncImage(url: URL(string: recipe.GeneralInfo.image)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipped()
                            } placeholder: {
                                Color.gray.frame(width: 80, height: 80)
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
            }
            .navigationTitle("Recipes")
        }
    }

    // MARK: - Networking
    private func fetchRecipes() {
        isLoading = true
        errorMessage = nil

        RecipeFetcher.shared.fetchRecipes(with: viewModel.ingredients) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let recipes):
                    viewModel.recipes = recipes
                case .failure(let error):
                    errorMessage = "Failed to get recipes: \(error.localizedDescription)"
                }
            }
        }
    }
}
