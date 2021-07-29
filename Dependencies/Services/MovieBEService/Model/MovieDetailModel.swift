//
//  MovieDetailModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 26/07/2021.
//

import Foundation
import UIKit
import Reusable

public struct MovieDetailModel: Model {
    public let id: Int
    public let posterImage: UIImage?
    public let title: String
    public let overview: String
    public let genres: [MovieGenre]
    public let releaseDate: String?
    public let voteAverage: Float?
    
    public init(id: Int, posterImage: UIImage?, title: String, overview: String, genres: [MovieGenre], releaseDate: String?, voteAverage: Float?) {
        self.id = id
        self.posterImage = posterImage
        self.title = title
        self.overview = overview
        self.genres = genres
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
    }
    
    public init(_ model: MovieModel, posterImage: UIImage? = nil) {
        self.id = model.id
        self.title = model.title
        self.overview = model.overview
        self.genres = model.genres
        self.releaseDate = model.releaseDate
        self.voteAverage = model.voteAverage
        self.posterImage = posterImage
    }
    
    public init() {
        id = -1
        posterImage = nil
        title = ""
        overview = ""
        genres = []
        releaseDate = nil
        voteAverage = nil
    }
}
