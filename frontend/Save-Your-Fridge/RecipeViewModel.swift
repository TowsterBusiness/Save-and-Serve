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
    
    // MARK: - Fetch Recipes
    func fetchRecipes() {
        guard let url = URL(string: "http://localhost:8000/test") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [RecipeResponse].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching recipes:", error)
                }
            }, receiveValue: { [weak self] recipes in
                self?.recipes = recipes
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Save Recipe
    func saveRecipe(_ recipe: RecipeResponse) {
        if !savedRecipes.contains(where: { $0.GeneralInfo.id == recipe.GeneralInfo.id }) {
            savedRecipes.append(recipe)
        }
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
