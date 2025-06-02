//
//  RecipesManagerTests.swift
//  RecipeList
//
//  Created by Trenton Lazorchak on 6/1/25.
//

import XCTest
@testable import RecipeList

/// Unit tests the RecipesManager cache implementation
final class RecipesManagerCacheTests: XCTestCase {

    /// A reusable mock recipe
    private let mockRecipe: Recipe = Recipe(
        cuisine: "Test Cuisine",
        name: "Test Name",
        photoURLLarge: nil,
        photoURLSmall: nil,
        uuid: "123",
        sourceURL: nil,
        youtubeURL: nil)

    /// Tests a valid storing and response for the cache
    func testCacheStoresAndReturnsValidResponse() async throws {
        let manager = RecipesManager()
        let mockResponse = RecipeResponse(recipes: [mockRecipe])

        // Cache the mock response
        try await manager.cacheData(mockResponse, forKey: "testKey")

        // Simulate valid cached data
        let cachedData = try await manager.getCachedData(forKey: "testKey")

        // Verify the data was stored to the cache and retrieved as not nil
        XCTAssertNotNil(cachedData)

        // Verify the data is decoded correctly
        let decoded = try JSONDecoder().decode(RecipeResponse.self, from: cachedData!)
        XCTAssertEqual(decoded.recipes.first, mockRecipe)
    }

    /// Tests an expired cache
    func testExpiredCacheReturnsNil() async throws {
        let manager = RecipesManager()
        let mockResponse = RecipeResponse(recipes: [mockRecipe])

        // Encode and insert a manually old timestamp
        let data = try JSONEncoder().encode(mockResponse)
        let expiredTimestamp = Date().addingTimeInterval(-3600 * 2) // 2 hours ago
        manager.cache["testKey"] = .init(data: data, timestamp: expiredTimestamp)

        // Verify trying to fetch this data from cache returns nil
        let result = try await manager.getCachedData(forKey: "testKey")
        XCTAssertNil(result)
    }

}
