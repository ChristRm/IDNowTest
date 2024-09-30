//
//  ImageViewModelTests.swift
//  IDNowTestTests
//
//  Created by Kristian Rusyn on 29/09/2024.
//

import Foundation
import XCTest
import Combine
@testable import IDNowTest

class ImageViewModelTests: XCTestCase {

    private var viewModel: ImageViewModel!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        
        // Injecting a mock URLSession with no cache
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let mockSession = URLSession(configuration: config)
        
        viewModel = ImageViewModel(image: UIImage(), session: mockSession)
    }

    override func tearDown() {
        // Clear ViewModel and Cancellables
        viewModel = nil
        cancellables = nil
        
        // Clear MockURLProtocol's stubbed data and error
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubResponseError = nil
        
        // Add a slight delay to ensure all asynchronous tasks are completed
        let waitExpectation = XCTestExpectation(description: "Waiting for async clean-up")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 0.5)
        
        super.tearDown()
    }
    
    func testFetchProductSetsTitlePriceAndDescription() {
        // Given
        let product = Product(id: 1, title: "Test Product", description: "A sample product", price: 19.99)
        let data = try! JSONEncoder().encode(product)
        MockURLProtocol.stubResponseData = data

        // Individual expectations
        let titleExpectation = XCTestExpectation(description: "Title updated")
        let priceExpectation = XCTestExpectation(description: "Price updated")
        let descriptionExpectation = XCTestExpectation(description: "Description updated")

        // Set up subscriptions before triggering the fetch
        viewModel.$title
            .dropFirst()
            .sink { title in
                print("Received title update in test: \(title)")
                XCTAssertEqual(title, "Test Product")
                titleExpectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.$price
            .dropFirst()
            .sink { price in
                XCTAssertEqual(price, "$19.99")
                priceExpectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.$description
            .dropFirst()
            .sink { description in
                XCTAssertEqual(description, "A sample product")
                descriptionExpectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchProduct()

        // Wait for all expectations
        wait(for: [titleExpectation, priceExpectation, descriptionExpectation], timeout: 15.0)
    }

    func testFetchProductSetsErrorMessageOnInvalidURL() {
        // Given
        MockURLProtocol.stubResponseError = URLError(.badURL)

        let expectation = XCTestExpectation(description: "Error message should be set")

        // Set up subscription before triggering the fetch
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                XCTAssertEqual(errorMessage, URLError(.badURL).localizedDescription)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchProduct()

        // Then
        wait(for: [expectation], timeout: 5.0)
    }

    func testIsLoadingStateDuringFetch() {
        // Given
        let product = Product(id: 1, title: "Test Product", description: "A sample product", price: 19.99)
        let data = try! JSONEncoder().encode(product)
        MockURLProtocol.stubResponseData = data

        let expectation1 = XCTestExpectation(description: "isLoading should be true when fetching starts")
        let expectation2 = XCTestExpectation(description: "isLoading should be false when fetching ends")

        // Set up subscription before triggering the fetch
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if isLoading {
                    expectation1.fulfill()
                } else {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchProduct()

        // Then
        wait(for: [expectation1, expectation2], timeout: 5.0)
    }
}


class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubResponseError: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        // This allows the mock to intercept all requests
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.stubResponseError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else if let data = MockURLProtocol.stubResponseData {
            let response = HTTPURLResponse(url: self.request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: ["Content-Type": "application/json"])!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // Required to override but no specific implementation needed
    }
}
