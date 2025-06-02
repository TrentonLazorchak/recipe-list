//
//  RecipeResponse.swift
//  RecipeList
//
//  Created by Trenton Lazorchak on 5/30/25.
//

/// Response for list of recipes
struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

/// An individual recipe
struct Recipe: Codable, Equatable {
    let cuisine: String
    let name: String
    let photoURLLarge: String?
    let photoURLSmall: String?
    let uuid: String
    let sourceURL: String?
    let youtubeURL: String?

    enum CodingKeys: String, CodingKey {
        case cuisine
        case name
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case uuid
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
}
