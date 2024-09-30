//
//  Model.swift
//  IDNowTest
//
//  Created by Kristian Rusyn on 22/09/2024.
//

import Foundation

struct Product: Codable {
    let id: Int
    let title: String
    let description: String
    let price: Double
}
