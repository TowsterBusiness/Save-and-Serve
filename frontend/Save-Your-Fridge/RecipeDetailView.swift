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
    
    @State private var showConfetti = false
    @State private var buttonFrame: CGRect = .zero
    @State private var isPressed = false
    @State private var isSaved = false
    
    var body: some View {
        GeometryReader { outerGeo in
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // MARK: - Recipe Image with Overlay
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(url: URL(string: recipe.GeneralInfo.image)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                                    )
                            }
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(radius: 6, y: 3)
                            .overlay(
                                // Gradient fade for text readability
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                                    startPoint: .bottom,
                                    endPoint: .center
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            )
                            
                            // MARK: - Nutrition & Price Overlay
                            VStack(alignment: .leading, spacing: 6) {
                                if let nutrition = recipe.nutrition {
                                    HStack(spacing: 12) {
                                        Label("\(nutrition.calories ?? "—") cal", systemImage: "flame.fill")
                                        Label("\(nutrition.protein ?? "—") protein", systemImage: "leaf.fill")
                                    }
                                    .font(.footnote)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                
                                if let price = recipe.price {
                                    Text(String(format: "$%.2f est.", price))
                                        .font(.footnote.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.9))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(12)
                        }
                        
                        // MARK: - Title
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.GeneralInfo.title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("\(recipe.GeneralInfo.usedIngredients.count) ingredients • \(recipe.instructions?.count ?? 0) steps")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // MARK: - Ingredients
                        if !recipe.GeneralInfo.usedIngredients.isEmpty {
                            SectionCard(title: "Ingredients") {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(recipe.GeneralInfo.usedIngredients, id: \.self) { ingredient in
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 6))
                                                .foregroundColor(.accentColor.opacity(0.7))
                                            Text(ingredient)
                                                .font(.body)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Instructions
                        if let instructions = recipe.instructions, !instructions.isEmpty {
                            SectionCard(title: "Instructions") {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(instructions.indices, id: \.self) { i in
                                        HStack(alignment: .top, spacing: 6) {
                                            Text("\(i + 1).")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.accentColor)
                                            Text(instructions[i])
                                                .font(.body)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Nutrition
                        if let nutrition = recipe.nutrition {
                            SectionCard(title: "Nutrition") {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Calories: \(nutrition.calories ?? "—")")
                                    Text("Fat: \(nutrition.fat ?? "—")")
                                    Text("Protein: \(nutrition.protein ?? "—")")
                                    Text("Carbohydrates: \(nutrition.carbohydrates ?? "—")")
                                }
                                .font(.body)
                            }
                        }
                        
                        // MARK: - Price
                        if let price = recipe.price {
                            SectionCard(title: "Estimated Price") {
                                Text(String(format: "$%.2f", price))
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        // MARK: - Save Button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                toggleSaveRecipe()
                            }
                        }) {
                            HStack {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                Text(isSaved ? "Saved" : "Save Recipe")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isSaved ? Color.green : Color.accentColor)
                            .cornerRadius(12)
                            .shadow(radius: 4, y: 2)
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear { buttonFrame = geo.frame(in: .named("scroll")) }
                                    .onChange(of: geo.frame(in: .named("scroll"))) { newFrame in
                                        buttonFrame = newFrame
                                    }
                            }
                        )
                        .padding(.top, 12)
                        .padding(.bottom, 40)
                    }
                    .padding()
                }
                .coordinateSpace(name: "scroll")
                .background(Color(.systemGroupedBackground))
                
                // MARK: - Confetti Overlay
                if showConfetti {
                    ConfettiView(originFrame: buttonFrame)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                isSaved = viewModel.isRecipeSaved(recipe)
            }
            .onDisappear {
                if isSaved && !viewModel.isRecipeSaved(recipe) {
                    viewModel.saveRecipe(recipe)
                } else if !isSaved && viewModel.isRecipeSaved(recipe) {
                    viewModel.unsaveRecipe(recipe)
                }
            }
        }
        .navigationTitle(recipe.GeneralInfo.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Save Logic
    private func toggleSaveRecipe() {
        if isSaved {
            isSaved = false
        } else {
            isSaved = true
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showConfetti = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showConfetti = false }
            }
        }
    }
}

// MARK: - Confetti Animation (Relative to Button)
struct ConfettiView: View {
    let originFrame: CGRect
    @State private var confettiOffsets: [CGSize] = (0..<30).map { _ in .zero }
    @State private var opacities: [Double] = Array(repeating: 1.0, count: 30)
    var body: some View {
        GeometryReader {
            geo in ForEach(0..<30, id: \.self) {
                i in
                Circle()
                    .fill(confettiColors.randomElement()!)
                    .frame(width: 8, height: 8) // Place relative to button’s current position
                    .position(x: originFrame.midX, y: originFrame.midY)
                    .offset(confettiOffsets[i]) .opacity(opacities[i])
                    .onAppear {
                        withAnimation(
                            .easeOut(duration: 1.0)
                            .delay(Double.random(in: 0...0.2)) ) {
                                confettiOffsets[i] = CGSize(
                                    width: CGFloat.random(in: -150...150),
                                    height: CGFloat.random(in: -250...(-100)) )
                                opacities[i] = 0
                            }
                    }
            }
        }
        .allowsHitTesting(false)
    }
    
    private let confettiColors: [Color] = [ .red, .green, .blue, .yellow, .pink, .purple, .orange ]
}
