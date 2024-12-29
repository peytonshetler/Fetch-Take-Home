//
//  RecipeModelTests.swift
//  FetchTakeHomeTests
//
//  Created by Peyton Shetler on 12/28/24.
//

import XCTest
@testable import FetchTakeHome

final class RecipeModelTests: XCTestCase {
    let testId: String = "0c6ca6e7-e32a-4053-b824-1dbf749910d8"
    let testCuisine: String = "Malaysian"
    let testName: String = "Apam Balik"
    let testLargeImageUrl: String = "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"
    let testSmallImageUrl: String = "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg"
    let testSourceUrl: String = "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"
    let testYoutubeUrl: String = "https://www.youtube.com/watch?v=6R8ffRRJcrg"
    let testFileName: String = "Apam-Balik-0c6ca6e7-e32a-4053-b824-1dbf749910d8"
    
    func testRecipeDecoding() {
        let jsonString = "{\"cuisine\":\"\(testCuisine)\",\"name\":\"\(testName)\",\"photo_url_large\":\"\(testLargeImageUrl)\",\"photo_url_small\":\"\(testSmallImageUrl)\",\"source_url\":\"\(testSourceUrl)\",\"uuid\":\"\(testId)\",\"youtube_url\":\"\(testYoutubeUrl)\"}"

        
        guard let mockJSONData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to convert JSON string to data")
            return
        }
        
        guard let recipe = try? JSONDecoder().decode(Recipe.self, from: mockJSONData) else {
            XCTFail("Failed to decode User object")
            return
        }
        
        XCTAssertEqual(recipe.id, testId, "Recipe ID should match")
        XCTAssertEqual(recipe.name, testName, "Recipe name should match")
        XCTAssertEqual(recipe.cuisine, testCuisine, "Recipe cuisine should match")
        XCTAssertEqual(recipe.smallImageUrl, testSmallImageUrl, "Recipe small image URL should match")
        XCTAssertEqual(recipe.largeImageUrl, testLargeImageUrl, "Recipe large image URL should match")
        XCTAssertEqual(recipe.sourceUrl, testSourceUrl, "Recipe source URL should match")
        XCTAssertEqual(recipe.youtubeUrl, testYoutubeUrl, "Recipe youtube URL should match")
        XCTAssertEqual(recipe.fileName, testFileName, "Recipe file name should match")
        XCTAssertEqual(recipe.imageUrl, testSmallImageUrl, "Recipe imageUrl should match the small image URL")
    }
}
