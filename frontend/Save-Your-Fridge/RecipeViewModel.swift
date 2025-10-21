//
//  RecipeViewModel.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//


import Foundation
import Combine

class RecipeViewModel: ObservableObject {
    @Published var recipes: [RecipeResponse] = []
    @Published var savedRecipes: [RecipeResponse] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
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
}
