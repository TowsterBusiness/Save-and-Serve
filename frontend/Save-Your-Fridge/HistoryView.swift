import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: RecipeViewModel

    var body: some View {
        Group {
            if viewModel.savedRecipes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark.slash.fill")
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
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.savedRecipes, id: \.GeneralInfo.id) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                                RecipeCard(recipe: recipe)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}

#Preview {
    HistoryView(viewModel: RecipeViewModel())
}
