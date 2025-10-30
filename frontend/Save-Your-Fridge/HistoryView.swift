import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: RecipeViewModel

    var body: some View {
        NavigationView {
            VStack {
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
                    // MARK: - Recipes List
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
                
            }
            .navigationTitle("Saved")
            
        }
        
    }
}
