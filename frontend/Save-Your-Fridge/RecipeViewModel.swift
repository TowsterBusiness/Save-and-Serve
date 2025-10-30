//
//  RecipeViewModel.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//


import Foundation
import Combine
import SwiftUI

class RecipeViewModel: ObservableObject {
    @Published var recipes: [RecipeResponse] = []
    @Published var savedRecipes: [RecipeResponse] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    @Published var ingredients: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadFromUserDefaults()
    }
    
    func storeRecipes(recipes: [RecipeResponse]) {
        self.recipes = recipes
    }
    
    // MARK: - Save Recipe
    func saveRecipe(_ recipe: RecipeResponse) {
        if !savedRecipes.contains(where: { $0.GeneralInfo.id == recipe.GeneralInfo.id }) {
            savedRecipes.append(recipe)
        }
    }
    
    // MARK: - Unsave Recipe
    func unsaveRecipe(_ recipe: RecipeResponse) {
        savedRecipes.removeAll { $0.GeneralInfo.id == recipe.GeneralInfo.id }
    }
    
    // MARK: - Check if Recipe Saved
    func isRecipeSaved(_ recipe: RecipeResponse) -> Bool {
        return savedRecipes.contains(where: { $0.GeneralInfo.id == recipe.GeneralInfo.id })
    }
    
    // MARK: - UserDefaults
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedRecipes) {
            UserDefaults.standard.set(encoded, forKey: "savedRecipes")
        }
    }
    
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "savedRecipes"),
           let decoded = try? JSONDecoder().decode([RecipeResponse].self, from: data) {
            savedRecipes = decoded
        }
    }
    
    func uploadImageAndFetchIngredients(_ image: UIImage) {
        ImageUploader.shared.uploadImageForIngredients(image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ingredientString):
                    self?.addIngredients(from: ingredientString)
                case .failure(let error):
                    print("❌ Failed to get ingredients:", error.localizedDescription)
                }
            }
        }
    }
    
    func addIngredient(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !ingredients.contains(trimmed) else { return }
        ingredients.insert(trimmed, at: 0)
    }

    func addIngredients(from string: String) {
        let parsed = string
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for ingredient in parsed where !ingredients.contains(ingredient) {
            ingredients.insert(ingredient, at: 0)
        }
    }

    func deleteIngredient(offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }

    func clearAllIngredients() {
        ingredients.removeAll()
    }


}
