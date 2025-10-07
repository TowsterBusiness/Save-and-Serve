//
//  RecipeDetailView.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//


import SwiftUI

struct RecipeDetailView: View {
    let recipe: RecipeResponse
    @ObservedObject var viewModel: RecipeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: recipe.GeneralInfo.image)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)
                .cornerRadius(12)
                
                Text(recipe.GeneralInfo.title)
                    .font(.largeTitle)
                    .bold()
                
                if let instructions = recipe.instructions, !instructions.isEmpty {
                    Text("Instructions:")
                        .font(.headline)
                    ForEach(instructions, id: \.self) { step in
                        Text("• \(step)")
                            .padding(.bottom, 2)
                    }
                }
                
                Button(action: {
                    viewModel.saveRecipe(recipe)
                }) {
                    Text("Save Recipe")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle(recipe.GeneralInfo.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
