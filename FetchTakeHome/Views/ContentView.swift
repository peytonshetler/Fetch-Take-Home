//
//  ContentView.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/23/24.
//

import SwiftUI

/// TODO:
/// UNIT TESTING
/// USER-INITIATED REFRESHING ✅
/// MALFORMED/EMPTY DATA HANDLING
/// "SHOW OFF YOUR SKILLS" PORTION
///
/// README
/// PUBLIC GITHUB REPO

struct ContentView: View {
    @State private var viewModel = RecipeViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.recipes, id: \.id) { recipe in
                HStack {
                    CachedAsyncImage(item: recipe)
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    
                    Spacer()
                    VStack(alignment: .trailing, spacing: 20) {
                        Text(recipe.name)
                            .font(.headline)
                        
                        Text(recipe.cuisine)
                            .foregroundStyle(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(.blue)
                            .clipShape(Capsule())
                    }
                    .frame(height: 90)
                }
            } // End List
            .refreshable {
                await viewModel.fetchRecipes()
            } // End Refreshable
            .overlay(Group {
                switch viewModel.state {
                case .loading:
                    ProgressView {
                        Text("Loading...")
                    }
                case .completed:
                    if viewModel.recipes.isEmpty {
                        Text("No Recipes")
                            .font(.system(size: 16))
                            .foregroundStyle(.tertiary)
                    }
                }
            }) // End Overlay
            .navigationTitle("Recipes")
        }
        .alert(
            viewModel.apiError?.title ?? "Error",
            isPresented: $viewModel.shouldShowAlert,
            actions: { Button("Ok") { viewModel.apiError = nil } },
            message: { Text(viewModel.apiError?.message ?? "") }
        )
        .task {
            await viewModel.fetchRecipes()
        }
    } // End Body
}

#Preview {
    ContentView()
}
