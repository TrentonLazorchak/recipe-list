//
//  RecipeListView.swift
//  RecipeList
//
//  Created by Trenton Lazorchak on 6/1/25.
//

import SwiftUI

/// A view displaying a list of recipes
struct RecipeListView: View {

    @State var viewModel: RecipeListViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.viewState {
                case .initial:
                    List {
                        Section(header: Text("Test header").redacted(reason: .placeholder)) {
                            ForEach(0..<10) { _ in
                                RecipeCellView(recipe: nil)
                            }
                        }
                    }
                    .scrollDisabled(true)
                case .loading:
                    ProgressView("Loading...")
                case .loaded:
                    List {
                        ForEach(viewModel.recipes.keys.sorted(), id: \.self) { key in
                            Section(header: Text(key)) {
                                ForEach(viewModel.recipes[key] ?? [], id: \.id) { recipeVM in
                                    RecipeCellView(recipe: recipeVM)
                                }
                            }
                        }
                    }
                    .refreshable {
                        Task {
                            await viewModel.loadRecipes(isRefresh: true)
                        }
                    }
                case .noRecipes:
                    EmptyStateView(text: "No Recipes Returned", retryAction: viewModel.loadRecipes)
                case .failure:
                    EmptyStateView(text: "An Error Has Occured", retryAction: viewModel.loadRecipes)
                }
            }
            .navigationTitle("Recipes")
            .task {
                await viewModel.loadRecipes(isRefresh: false)
            }
        }
    }

    /// View for an inidividual recipe cell
    private struct RecipeCellView: View {
        let recipe: RecipeCellViewModel?

        var body: some View {
            ZStack {
                // Loaded
                if let recipe {
                    NavigationLink {
                        RecipeView(
                            name: recipe.name,
                            cuisine: recipe.cuisine,
                            photoURL: recipe.largePhotoURL,
                            sourceURL: recipe.sourceURL,
                            youtubeURL: recipe.youtubeURL
                        )
                    } label: {
                        HStack {
                            // Show image if not nil
                            if let photoURL = recipe.photoURL,
                               let url = URL(string: photoURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                        .foregroundStyle(.gray)
                                        .redacted(reason: .placeholder)
                                }
                                .frame(width: 75, height: 75)
                            }

                            Text(recipe.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                    }
                } else {
                    // Initial view
                    HStack {
                        Rectangle()
                            .foregroundStyle(.gray)
                            .redacted(reason: .placeholder)
                            .frame(width: 75, height: 75)

                        Text("Intial Recipe Name")
                            .font(.headline)
                            .redacted(reason: .placeholder)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Reusable view for the empty and failure state
    private struct EmptyStateView: View {
        let text: String
        let retryAction: (Bool) async -> Void

        var body: some View {
            VStack(spacing: 12) {
                Text(text)
                    .font(.title)

                Button {
                    Task {
                        await retryAction(true)
                    }
                } label: {
                    Text("Retry")
                        .font(.title2)
                }
            }
        }
    }

}

#Preview("Success") {
    RecipeListView(viewModel: .init(manager: MockRecipesManager.sampleSuccess))
}

#Preview("Empty") {
    RecipeListView(viewModel: .init(manager: MockRecipesManager.sampleEmpty))
}

#Preview("Failure") {
    RecipeListView(viewModel: .init(manager: MockRecipesManager.sampleFailure))
}
