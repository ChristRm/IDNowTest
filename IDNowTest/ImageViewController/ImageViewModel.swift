//
//  ImageViewModel.swift
//  IDNowTest
//
//  Created by Kristian Rusyn on 22/09/2024.
//

import Combine
import Foundation
import UIKit

class ImageViewModel: ObservableObject {

    enum Constants {
        static let productsUrl = "https://dummyjson.com/products/1"
    }

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var image: UIImage?

    @Published var title: String = ""
    @Published var price: String = ""
    @Published var description: String = ""
    
    private var session: URLSession
    private var cancellables = Set<AnyCancellable>()

    init(image: UIImage, session: URLSession = .shared) {
        self.image = image
        self.session = session
    }

    func fetchProduct() {
        guard let url = URL(string: Constants.productsUrl) else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true

        session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Product.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    print("Completion error: \(error)") // Debugging Log
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] product in
                print("Received product: \(product.title)") // Debugging log
                self?.title = product.title
                self?.price = "$\(product.price)"
                self?.description = product.description
            })
            .store(in: &cancellables)
    }
}
