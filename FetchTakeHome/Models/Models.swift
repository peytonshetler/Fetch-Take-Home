//
//  Models.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/23/24.
//

import Foundation



protocol ImageCacheable {
    var fileName: String { get }
    var largeImageUrl: String? { get }
    var smallImageUrl: String? { get }
}

struct RecipeResponse: Decodable {
    var recipes: [Recipe]
}

enum RecipeVMNetworkState {
    case loading, completed
}

struct Recipe: Decodable, Identifiable, ImageCacheable {
    var id: String
    var cuisine: String
    var name: String
    var largeImageUrl: String?
    var smallImageUrl: String?
    var sourceUrl: String?
    var youtubeUrl: String?
    
    // This will be used if/when we save the Recipe's image data to disk.
    var fileName: String {
        let updatedName: String = name.replacingOccurrences(of: " ", with: "-")
        return "\(updatedName)-\(id)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case cuisine
        case name
        case largeImageUrl = "photo_url_large"
        case smallImageUrl = "photo_url_small"
        case sourceUrl = "source_url"
        case youtubeUrl = "youtube_url"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.cuisine = try container.decode(String.self, forKey: .cuisine)
        self.name = try container.decode(String.self, forKey: .name)

        self.largeImageUrl = try container.decodeIfPresent(String.self, forKey: .largeImageUrl)
        self.smallImageUrl = try container.decodeIfPresent(String.self, forKey: .smallImageUrl)
        self.sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        self.youtubeUrl = try container.decodeIfPresent(String.self, forKey: .youtubeUrl)
    }
}

@Observable
class RecipeViewModel {
    var recipes: [Recipe] = []
    var apiError: APIError? = nil
    var state: RecipeVMNetworkState = .completed
    var shouldShowAlert: Bool = false
    
    private func handleError(error: APIError) {
        apiError = error
        state = .completed
        shouldShowAlert = true
    }

    func fetchRecipes() async {
        state = .loading

        do {
            let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
            guard let url = url else {
                handleError(error: .badURL)
                return
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                guard (200...299).contains(statusCode) else {
                    handleError(error: .invalidStatusCode(statusCode: statusCode))
                    return
                }
            }
            let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
            recipes = recipeResponse.recipes
            
            state = .completed
        } catch {
            handleError(error: .unknown)
        }
    }
}
