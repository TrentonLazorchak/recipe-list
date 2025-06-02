//
//  RecipeListTests.swift
//  RecipeListTests
//
//  Created by Trenton Lazorchak on 5/30/25.
//

import XCTest
@testable import RecipeList

/// Unit tests for the recipe list view model
@MainActor
final class RecipeListViewModelTests: XCTestCase {

    /// Tests the happy path scenario and returned recipes for the view model.
    func testLoadRecipesSuccess() async {
        let viewModel = RecipeListViewModel(manager: MockRecipesManager.sampleSuccess)

        XCTAssertEqual(viewModel.viewState, .initial)

        await viewModel.loadRecipes(isRefresh: false)

        XCTAssertEqual(viewModel.viewState, .loaded)

        // Confirm recipes
        let expectedRecipes: [RecipeCellViewModel] = [.init(
            id: "123",
            cuisine: "Test Cuisine",
            name: "Test Name",
            photoURL: "testSM.com",
            largePhotoURL: "test.com",
            sourceURL: "testsource.com",
            youtubeURL: "youtube-test.com"
        )]
        XCTAssertEqual(viewModel.recipes, ["Test Cuisine": expectedRecipes])
    }

    /// Tests the happy path scenario and returned recipes are empty for the view model.
    func testLoadRecipesEmpty() async {
        let viewModel = RecipeListViewModel(manager: MockRecipesManager.sampleEmpty)

        XCTAssertEqual(viewModel.viewState, .initial)

        await viewModel.loadRecipes(isRefresh: false)

        XCTAssertEqual(viewModel.viewState, .noRecipes)

        // Confirm recipes
        XCTAssertEqual(viewModel.recipes, [:])
    }

    /// Tests the unhappy path scenario for the view model.
    func testLoadRecipesError() async {
        let viewModel = RecipeListViewModel(manager: MockRecipesManager.sampleFailure)

        XCTAssertEqual(viewModel.viewState, .initial)

        await viewModel.loadRecipes(isRefresh: false)

        XCTAssertEqual(viewModel.viewState, .failure)
    }

}
