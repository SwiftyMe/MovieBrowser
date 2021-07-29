//
//  MoviesModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 17/06/2021.
//


import Foundation


struct TMDBMoviesModel: Codable {
    let page: Int?
    let results: [TMDBMovieModel]?
    let totalResults: Int?
    let totalPages: Int?
}

extension TMDBMoviesModel {
    
    ///
    /// Translate to camel casing
    ///
    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case page, results
    }
}
