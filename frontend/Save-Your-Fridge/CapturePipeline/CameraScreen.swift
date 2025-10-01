//
//  CameraScreen.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//


import SwiftUI

struct CameraScreen: View {
    @State private var showCamera = false
    @State private var image: UIImage?
    @State private var responseText = "No response yet"

    var body: some View {
        VStack(spacing: 20) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }

            Button("Take Photo") {
                showCamera = true
            }
            .padding()

            Button("Upload Photo") {
                if let image = image {
                    ImageUploader.shared.uploadImage(image) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                responseText = response
                            case .failure(let error):
                                responseText = "Error: \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
            .padding()

            Text(responseText)
                .padding()
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $image)
        }
        .navigationTitle("Camera Upload")
    }
}
