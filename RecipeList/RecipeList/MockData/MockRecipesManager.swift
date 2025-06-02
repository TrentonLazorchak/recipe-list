//
//  MockRecipesManager.swift
//  RecipeList
//
//  Created by Trenton Lazorchak on 6/1/25.
//

// Only includes in debug builds and automated test targets. Excludes this code from release
#if DEBUG || canImport(XCTest)
import Foundation

/// Mock recipes managing for automated tests and previews
final class MockRecipesManager: RecipesManaging {
    let recipeResult: Result<RecipeResponse, Error>

    init(recipeResult: Result<RecipeResponse, Error>) {
        self.recipeResult = recipeResult
    }

    func getAllRecipes(useCache: Bool) async throws -> RecipeResponse {
        switch recipeResult {
        case .success(let response): return response
        case .failure(let error): throw error
        }
    }

    static var sampleSuccess: MockRecipesManager {
        .init(recipeResult: .success(.init(recipes: [
            .init(
                cuisine: "Test Cuisine",
                name: "Test Name",
                photoURLLarge: "test.com",
                photoURLSmall: "testSM.com",
                uuid: "123",
                sourceURL: "testsource.com",
                youtubeURL: "youtube-test.com"
            )
        ])))
    }

    static var sampleEmpty: MockRecipesManager {
        .init(recipeResult: .success(.init(recipes: [])))
    }

    static var sampleFailure: MockRecipesManager {
        .init(recipeResult: .failure(URLError(.badServerResponse)))
    }
}
#endif
