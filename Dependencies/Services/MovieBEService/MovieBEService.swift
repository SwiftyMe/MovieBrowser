//
//  MovieBEService.swift
//  MovieBEService
//
//  Created by Anders Lassen on 25/07/2021.
//

import Combine

public enum MovieList: CaseIterable {
    
    case popular, topRated, upComing
}

public struct MovieServiceError: Error {}

public protocol MovieServiceErrorDelegate {
    
    func error(_: MovieServiceError)
}

public protocol MovieServiceBrowseDelegate: MovieServiceErrorDelegate {
    
    func newMovies(list: MovieList, models: [MovieModel])
    
    func genresUpdated() 
}

public protocol MovieServiceDetailDelegate: MovieServiceErrorDelegate {
    
    func movieDetail(model: MovieDetailModel)
}

public protocol MovieServiceBrowseItemDelegate: MovieServiceErrorDelegate {
    
    func updateMovie(model: MovieModel)
}


public protocol MovieService {
    
    typealias ModelId = Int
    
    /// Delegates
    
    var browseDelegate: MovieServiceBrowseDelegate? { get set }
    var detailDelegate: MovieServiceDetailDelegate? { get set }
    
    /// Properties
    
    var allGenres: [MovieGenre] { get }
    
    /// Functions
    
    func fetchItems(list: MovieList)
    
    func fetchDetailModel(model: MovieModel)

    func updateItemWhenVisible(model: MovieModel, delegate: MovieServiceBrowseItemDelegate)
    
    func itemBecameVisible(id: ModelId)
}


