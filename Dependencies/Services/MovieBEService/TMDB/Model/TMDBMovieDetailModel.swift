//
//  MovieDetailModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 20/07/2021.
//

import Foundation

struct TMDBMovieDetailModel: Codable {
    let id: Int
    let posterPath: String?
    let title: String?
    let overview: String?
    let releaseDate: String?
    let genres: [TMDBGenreModel]?
    let voteAverage: Float?
}

extension TMDBMovieDetailModel {
    
    ///
    /// Translate to camel casing
    ///
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case title, overview, id, genres
    }
}
