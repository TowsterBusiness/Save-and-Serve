//
//  ImageUploader.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/1/25.
//

import UIKit

class ImageUploader {
    static let shared = ImageUploader()
    private init() {}

    // MARK: - Upload image to get ingredients
    func uploadImageForIngredients(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://saveyourfridge-backend.onrender.com/getIngredients") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0)))
                return
            }

            do {
                // Response is { "response": "Jam, Dressing, Mustard, ..." }
                struct IngredientResponse: Decodable {
                    let response: String
                }

                let decoded = try JSONDecoder().decode(IngredientResponse.self, from: data)
                completion(.success(decoded.response))

            } catch {
                print("❌ JSON decoding failed:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw backend response:\n\(raw)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
