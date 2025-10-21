//
//  CameraScreen.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//

import SwiftUI

struct CameraScreen: View {
    @ObservedObject var viewModel: RecipeViewModel
    
    @State private var showCamera = false
    @State private var image: UIImage?
    @State private var responseText = "No response yet"
    @State private var isLoading = false
    
    // 👈 Add this environment variable
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: - Image Preview
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Text("No Photo Yet")
                                .foregroundColor(.gray)
                        )
                }

                // MARK: - Camera + Upload Buttons
                Button("📸 Take Photo") {
                    showCamera = true
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Button("⬆️ Upload Photo") {
                    uploadImage()
                }
                .buttonStyle(.bordered)
                .disabled(image == nil || isLoading)

                // MARK: - Loading / Response
                if isLoading {
                    ProgressView("Uploading...")
                        .padding()
                } else {
                    Text(responseText)
                        .padding()
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showCamera) {
                CameraView(image: $image)
            }
            .navigationTitle("Camera Upload")
        }
    }

    // MARK: - Upload Logic
    private func uploadImage() {
        guard let image = image else { return }
        isLoading = true
        responseText = "Uploading image..."

        ImageUploader.shared.uploadImage(image) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    responseText = "Upload successful!"
                    print("Server response: \(response)")
                    
                    // Store recipes
                    viewModel.storeRecipes(recipes: response)
                    
                    // 👇 Pop back to previous screen after short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        dismiss()
                    }

                case .failure(let error):
                    responseText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
