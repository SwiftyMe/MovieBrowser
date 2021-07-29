//
//  MovieModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 16/06/2021.
//

import Foundation

struct TMDBMovieModel: Codable {
    let id: Int
    let posterPath: String?
    let title: String?
    let overview: String?
    let releaseDate: String?
    let genres: [Int]?
    let voteAverage: Float?
}

extension TMDBMovieModel {
    
    ///
    /// Translate to camel casing
    ///
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case genres = "genre_ids"
        case voteAverage = "vote_average"
        case title, overview, id
    }
}
