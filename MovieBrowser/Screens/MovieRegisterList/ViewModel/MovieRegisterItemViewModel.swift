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
import MovieBEService

///
/// View-model class for a user-registered movie
///
class MovieRegisterItemViewModel: ObservableObject, IdentifiableHashable, ViewLifeCycleEvents, ModelObjectOptionalAccessor  {
    
    /// Identifiable conformance
    var id: Int {
        Int(movie.tmdbId)
    }
    
    /// ModelObjectAccessor conformance
    var modelObject: MovieDetailModel? {
        model
    }
    
    var registeredMovie: DBMovie {
        movie
    }
    
    @Published var title: String = ""
    @Published var overview: String = ""
    @Published var posterImage: UIImage? = nil
    @Published var rating: String = "My Rating:"
    
    func onAppear() {
        
        print("MovieRegisterItemViewModel - onAppear \(id)")
        
        // assert(!appearing) TODO: check why this happens

        self.updatePropertyRating()
        
        guard !appeared else {
            return
        }

        movieService.fetchDetailModel(id: Int(movie.tmdbId))
    
        appeared = true
    }
    
    func onDisappear() {
        
        print("MovieRegisterItemViewModel - onDisappear")
    }

    init(movie: DBMovie, service: MovieService) {
      
        print("\(type(of: self)) - init \(movie.tmdbId)")
        
        self.movie = movie
        self.movieService = service
    }
    
    deinit {
        print("\(type(of: self)) - deinit \(id)")
    }
    
    private var movie: DBMovie
    private var model: MovieDetailModel?
    private var movieService: MovieService
    private var appeared = false
}

extension MovieRegisterItemViewModel {
    
    private func updateProperties() {
        print("MovieRegisterItemViewModel - updateProperties \(movie.tmdbId)")
        updatePropertyTitle()
        updatePropertyOverview()
        updatePropertyPosterImage()
    }
    
    private func updatePropertyTitle() {
        title = modelObject?.title ?? ""
    }
    
    private func updatePropertyOverview() {
        overview = modelObject?.overview ?? ""
    }
    
    private func updatePropertyPosterImage() {
        posterImage = modelObject?.posterImage
    }

    private func updatePropertyRating() {
        rating = movie.rating == 0 ? "My Rating:" : String(format: "My Rating: %.1f", 0.1 * Double(movie.rating))
    }
}

extension MovieRegisterItemViewModel {
    
    func updateModel(model: MovieDetailModel) {
        self.model = model
        updateProperties()
    }
}


