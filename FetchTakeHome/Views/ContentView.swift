//
//  ContentView.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/23/24.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = RecipeViewModel()
    let urlString: String = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"

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
                await viewModel.fetchRecipes(urlString: urlString)
            } // End Refreshable
            .overlay(Group {
                switch viewModel.networkState {
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
        ) // End Alert
        .task {
            await viewModel.fetchRecipes(urlString: urlString)
        } // End Task
    } // End Body
}

#Preview {
    ContentView()
}


@Observable
class RecipeViewModel {
    var recipes: [Recipe] = []
    var apiError: APIError? = nil
    var networkState: RecipeVMNetworkState = .completed
    var shouldShowAlert: Bool = false
    
    private func setError(error: APIError) {
        apiError = error
        networkState = .completed
        shouldShowAlert = true
    }

    func fetchRecipes(urlString: String) async {
        networkState = .loading

        do {
            let url = URL(string: urlString)
            guard let url = url else {
                setError(error: .badURL)
                return
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                guard (200...299).contains(statusCode) else {
                    setError(error: .invalidStatusCode(statusCode: statusCode))
                    return
                }
            }
            let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
            recipes = recipeResponse.recipes
            networkState = .completed
        } catch {
            setError(error: .unknown)
        }
    }
}
