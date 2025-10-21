//
//  RecipeCard.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/20/25.
//

import SwiftUI

struct RecipeCard: View {
    let recipe: RecipeResponse

    var body: some View {
        HStack(spacing: 16) {
            // Image
            AsyncImage(url: URL(string: recipe.GeneralInfo.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    )
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(radius: 2, y: 1)

            // Text info
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.GeneralInfo.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.accentColor.opacity(0.8))
                    Text("\(recipe.GeneralInfo.usedIngredients.count) ingredients")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
