//
//  IngredientsView.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/21/25.
//

import SwiftUI

struct IngredientsView: View {
    @ObservedObject var viewModel: RecipeViewModel
    @State private var newIngredient = ""

    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Add Ingredient Field
                HStack {
                    TextField("Add ingredient...", text: $newIngredient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button(action: {
                        viewModel.addIngredient(newIngredient)
                        newIngredient = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical)

                // MARK: - Ingredients List
                if viewModel.ingredients.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.slash.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No saved recipes yet.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .italic()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                } else {
                    Text("Swipe to remove ingredients!")
                        .foregroundColor(.secondary)
                    List {
                        ForEach(viewModel.ingredients, id: \.self) { ingredient in
                            Text(ingredient)
                        }
                        .onDelete(perform: deleteIngredient)
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                // MARK: - Buttons
                HStack(spacing: 20) {
                    Button("Load Sample Ingredients") {
                        let sampleResponse = "Jam, Dressing, Mustard, Salsa, Pickles, Maple Syrup, Yogurt, Milk, Creamer, Hummus, Eggs, Strawberries, Blueberries, Bell Peppers, Carrots, Oranges, Apples, Lettuce, Spinach, Deli Meat, Cheese, Butter, Bread, Juice, Water, Hot Sauce, Ketchup, Mayonnaise, Lemon Juice, Limes, Olives, Pesto, Soy Sauce, Tortillas, Sliced Cheese, Fruit Preserves"
                        viewModel.addIngredients(from: sampleResponse)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Clear All") {
                        withAnimation {
                            viewModel.clearAllIngredients()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.bottom)
            }
            .navigationTitle("Ingredients")
        }
    }

    // MARK: - Delete Single Ingredient
    private func deleteIngredient(at offsets: IndexSet) {
        viewModel.deleteIngredient(offsets: offsets)
    }
}
