//
//  MoviesModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 17/06/2021.
//


import Foundation


struct MoviesModel: Codable {
    let page: Int?
    let results: [MovieModel]?
    let totalResults: Int?
    let totalPages: Int?
}

extension MoviesModel {
    
    ///
    /// Translate to camel casing
    ///
    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case page, results
    }
}
