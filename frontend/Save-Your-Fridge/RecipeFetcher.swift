//
//  RecipeFetcher.swift
//  Save-Your-Fridge
//
//  Created by Towster on 10/21/25.
//


import Foundation

class RecipeFetcher {
    static let shared = RecipeFetcher()
    private init() {}

    func fetchRecipes(with ingredients: [String], completion: @escaping (Result<[RecipeResponse], Error>) -> Void) {
        guard let url = URL(string: "https://saveyourfridge-backend.onrender.com/getRecipies") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ✅ Backend expects JSON with "Ingredients" key
        let payload: [String: Any] = ["Ingredients": ingredients]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                struct ResponseWrapper: Decodable {
                    let response: [RecipeResponse]
                }

                let decoded = try JSONDecoder().decode(ResponseWrapper.self, from: data)
                completion(.success(decoded.response))
            } catch {
                print("❌ JSON decoding failed:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response:\n\(raw)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
