//
//  CachedAsyncImageViewModelTests.swift
//  FetchTakeHomeTests
//
//  Created by Peyton Shetler on 12/28/24.
//

import Foundation

import XCTest
@testable import FetchTakeHome

fileprivate struct  MockImageCacheableItem: ImageCacheable {
    var fileName: String = "Mock-Test-Item"
    var imageUrl: String? = "https://d3jbb8n5wk0qxi.cloudfront.net/photos/dd936646-8100-4a1c-b5ce-5f97adf30a42/small.jpg"
}

@MainActor
final class CachedAsyncImageViewModelTests: XCTestCase {
    
    var viewModel: CachedAsyncImageVM?
    
    override func setUp() {
        viewModel = CachedAsyncImageVM(item: MockImageCacheableItem())
    }
    
    func testSaveImageToDisk() async {
        // Load image from URL
        let expectation = XCTestExpectation(description: #function)
        let image: UIImage? = await viewModel?.loadImageFromURL()
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 7.0)
        XCTAssertTrue(image != nil, "Image should not be nil")
        
        // Save image to disk
        viewModel?.saveImageToDisk(image: image)
        
        // Load from Disk
        let loadedImage: UIImage? = viewModel?.fetchSavedImageFromDisk()
        XCTAssertTrue(loadedImage != nil, "Loaded Image from disk should not be nil")
    }
}
