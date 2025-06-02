//
//  RecipeListViewModel.swift
//  RecipeList
//
//  Created by Trenton Lazorchak on 6/1/25.
//

import SwiftUI

/// The model for an individual recipe in the Recipe List
struct RecipeCellViewModel: Identifiable, Equatable {
    let id: String
    let cuisine: String
    let name: String
    let photoURL: String?
    let largePhotoURL: String?
    let sourceURL: String?
    let youtubeURL: String?
}

/// The view model for holding business logic in the RecipeListView
@Observable @MainActor
final class RecipeListViewModel {

    let manager: RecipesManaging

    init(manager: RecipesManaging = RecipesManager()) {
        self.manager = manager
    }

    var viewState: ViewState = .initial
    enum ViewState {
        case initial
        case loading
        case loaded
        case noRecipes
        case failure
    }

    /// A dictionary of recipes with a key of the cuisine
    var recipes: [String: [RecipeCellViewModel]] = [:]

    /// Loads the recipes from the passed in manager
    /// - Parameter isRefresh: Whether or not the current request is the initial fetch or a refresh
    func loadRecipes(isRefresh: Bool) async {
        viewState = isRefresh ? .loading : .initial

        do {
            let recipeResponse = try await manager.getAllRecipes(useCache: !isRefresh)

            // Convert response into the recipe cell view model dictionary
            recipes = Dictionary(
                grouping: recipeResponse.recipes.map {
                    .init(
                        id: $0.uuid,
                        cuisine: $0.cuisine,
                        name: $0.name,
                        photoURL: $0.photoURLSmall,
                        largePhotoURL: $0.photoURLLarge,
                        sourceURL: $0.sourceURL,
                        youtubeURL: $0.youtubeURL
                    )
                },
                by: { $0.cuisine }
            )

            viewState = recipes.isEmpty ? .noRecipes : .loaded
        } catch {
            viewState = .failure
        }
    }

}
