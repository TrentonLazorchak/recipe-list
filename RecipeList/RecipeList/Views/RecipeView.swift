//
//  RecipeView.swift
//  RecipeList
//
//  Created by Trenton Lazorchak on 6/1/25.
//

import SwiftUI

/// View for an individual recipe
struct RecipeView: View {

    let name: String
    let cuisine: String
    let photoURL: String?
    let sourceURL: String?
    let youtubeURL: String?

    var body: some View {
        VStack(spacing: 0) {
            // Name
            Text(name)
                .font(.title)

            // Photo
            if let photoURL = photoURL,
               let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                } placeholder: {
                    Rectangle()
                        .foregroundStyle(.gray)
                        .redacted(reason: .placeholder)
                }
                .frame(width: 200, height: 200)
                .padding(.top, 12)
            }

            // URLs
            VStack(spacing: 12) {
                // Source URL
                if let sourceURL,
                   let url = URL(string: sourceURL) {
                    Link("Visit Website", destination: url)
                }

                // Youtube URL
                if let youtubeURL,
                   let url = URL(string: youtubeURL) {
                    Link("YouTube", destination: url)
                }
            }
            .padding(.top, 24)
        }
        .navigationTitle(cuisine)
        .navigationBarTitleDisplayMode(.inline)
        .padding(12)
    }
}

#Preview {
    NavigationView {
        RecipeView(
            name: "Apam Balik",
            cuisine: "Malaysian",
            photoURL: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
            sourceURL: "google.com",
            youtubeURL: "google.com"
        )
    }
}
