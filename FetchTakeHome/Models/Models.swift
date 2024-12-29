//
//  Models.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/23/24.
//

import Foundation

protocol ImageCacheable {
    var fileName: String { get }
    var imageUrl: String? { get }
}

struct RecipeResponse: Decodable {
    var recipes: [Recipe]
}

enum RecipeVMNetworkState {
    case loading, completed
}

struct Recipe: Decodable, Identifiable {
    var id: String
    var cuisine: String
    var name: String
    var largeImageUrl: String?
    var smallImageUrl: String?
    var sourceUrl: String?
    var youtubeUrl: String?
    
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

extension Recipe: ImageCacheable {
    var fileName: String {
        let updatedName: String = name.replacingOccurrences(of: " ", with: "-")
        return "\(updatedName)-\(id)"
    }
    
    var imageUrl: String? {
        return smallImageUrl
    }
}


