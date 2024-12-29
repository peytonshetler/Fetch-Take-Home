//
//  RecipeViewModelTests.swift
//  FetchTakeHomeTests
//
//  Created by Peyton Shetler on 12/28/24.
//

import XCTest
@testable import FetchTakeHome

@MainActor
final class RecipeViewModelTests: XCTestCase {
    enum RecipeTestURL: String {
        case prod = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
        case malformed = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
        case empty = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
    }
    
    var viewModel: RecipeViewModel?
    
    override func setUp() {
        viewModel = RecipeViewModel()
    }
    
    // Happy Path
    func testViewModelFetchRecipes() async {
        let expectation = XCTestExpectation(description: #function)
        await viewModel?.fetchRecipes(urlString: RecipeTestURL.prod.rawValue)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 7.0)
        
        XCTAssertNotEqual(viewModel?.recipes.count, 0, "Recipes should not be empty")
        XCTAssertEqual(viewModel?.shouldShowAlert, false, "viewModel.shouldShowAlert should be false")
        XCTAssertEqual(viewModel?.networkState, RecipeVMNetworkState.completed, "viewModel.state should be equal to completed")
        XCTAssertTrue(viewModel?.apiError == nil, "viewModel.apiError should be nil")
    }
    
    func testMalformedData() async {
        let expectation = XCTestExpectation(description: #function)
        await viewModel?.fetchRecipes(urlString: RecipeTestURL.malformed.rawValue)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 7.0)
        
        XCTAssertEqual(viewModel?.recipes.count, 0, "Recipes should be empty")
        XCTAssertEqual(viewModel?.shouldShowAlert, true, "viewModel.shouldShowAlert should be true")
        XCTAssertEqual(viewModel?.networkState, RecipeVMNetworkState.completed, "viewModel.state should be equal to completed")
        XCTAssertTrue(viewModel?.apiError != nil, "viewModel.apiError should not be nil")
    }
    
    func testEmptyData() async {
        let expectation = XCTestExpectation(description: #function)
        await viewModel?.fetchRecipes(urlString: RecipeTestURL.empty.rawValue)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 7.0)
        
        XCTAssertEqual(viewModel?.recipes.count, 0, "Recipes should be empty")
        XCTAssertEqual(viewModel?.shouldShowAlert, false, "viewModel.shouldShowAlert should be false")
        XCTAssertEqual(viewModel?.networkState, RecipeVMNetworkState.completed, "viewModel.state should be equal to completed")
        XCTAssertTrue(viewModel?.apiError == nil, "viewModel.apiError should be nil")
    }
}
