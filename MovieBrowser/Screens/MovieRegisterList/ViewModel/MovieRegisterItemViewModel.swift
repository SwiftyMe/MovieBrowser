//
//  File.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 16/07/2021.
//


import Foundation
import SwiftUI
import Combine
import Reusable

///
/// View-model class for a user-registered movie
///
class MovieRegisterItemViewModel: ObservableObject, Identifiable, Hashable, JSONModelObjectAccessor, ViewLifeCycleEvents  {
    
    static func == (lhs: MovieRegisterItemViewModel, rhs: MovieRegisterItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Identifiable conformance
    var id: Int {
        Int(movie.tmdbId)
    }
    
    /// ModelObjectAccessor conformance
    var modelObject: MovieDetailModel {
        if let model = model {
            return model
        }
        return MovieDetailModel(id:-1, posterPath:nil, title:nil, overview:nil, releaseDate:nil, genres:nil, voteAverage: nil)
    }
    
    var registeredMovie: DBMovie {
        movie
    }
    
    @Published var title: String = ""
    @Published var overview: String = ""
    @Published var rating: String = "My Rating:"
    @Published var posterImage: UIImage? = nil
    
    func onAppear() {
        
        print("MovieRegisterItemViewModel - onAppear \(id)")
        
        // assert(!appearing) TODO: check why this happens

        self.updateRating()
        
        guard !appeared else {
            return
        }

        updateMovieModel()
    
        appeared = true
    }
    
    func onDisappear() {
        
        print("MovieRegisterItemViewModel - onDisappear")
    }

    init(movie: DBMovie, api: MovieAPI) {
      
        print("MovieRegisterItemViewModel - init \(movie.tmdbId)")
        
        self.movie = movie
        self.api = api
        self.model = nil
    }
    
    deinit {
        
        print("MovieRegisterItemViewModel - deinit \(movie.tmdbId)")
    }
    
    private var movie: DBMovie
    private var model: MovieDetailModel?
    private let api: MovieAPI
    
    private var cancellable: AnyCancellable?
    private var appeared = false
}


extension MovieRegisterItemViewModel {
    
    private func updateMovieModel() {
        
        cancellable = api.movieDetail(id: Int(movie.tmdbId)).sink(receiveCompletion: { completion in
            print("MovieRegisterItemViewModel - receiveCompletion")
        },
        receiveValue: { [weak self] value in
            guard let self = self else { return }
            self.model = value
            self.updateTitle()
            self.updateOverview()
            self.updatePosterImage()
            self.updateRating()
        })
    }
    
    private func updatePosterImage() {

        guard let posterPath = model?.posterPath else {
            return
        }
            
        cancellable = api.mediaObject(path:posterPath, size:200, type:.JPG).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] value in
                self?.posterImage = value
            })
    }

    func updateTitle() {
        title = model?.title ?? ""
    }
    
    func updateOverview() {
        overview = model?.overview ?? ""
    }
    
    func updateRating() {
        rating = movie.rating == 0 ? "My Rating:" : String(format: "My Rating: %.1f", 0.1 * Double(movie.rating))
    }
}

