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

    func uploadImage(_ image: UIImage, completion: @escaping (Result<[RecipeResponse], Error>) -> Void) {
        guard let url = URL(string: "https://saveyourfridge-backend.onrender.com/getRecipiesTest") else {
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
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                // Decode wrapper object
                struct ResponseWrapper: Decodable {
                    let response: [RecipeResponse]
                }

                let wrapper = try decoder.decode(ResponseWrapper.self, from: data)
                completion(.success(wrapper.response))
            } catch {
                print("❌ JSON Decoding failed:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw backend response:\n\(raw)")
                }
                completion(.failure(error))
            }

        }.resume()
    }
}
