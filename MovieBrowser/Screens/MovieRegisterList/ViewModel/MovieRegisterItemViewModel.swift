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
class MovieRegisterItemViewModel: ObservableObject, Identifiable, Hashable, ModelObjectOptionalAccessor, ViewLifeCycleEvents  {

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
    var modelObject: MovieDetailModel? {
        model
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

    init(movie: DBMovie, service: MovieService) {
      
        print("MovieRegisterItemViewModel - init \(movie.tmdbId)")
        
        self.movie = movie
        self.service = service
        self.model = nil
    }
    
    deinit {
        
        print("MovieRegisterItemViewModel - deinit \(movie.tmdbId)")
    }
    
    private var movie: DBMovie
    private var model: MovieDetailModel?
    private let service: MovieService
    private var appeared = false
}


extension MovieRegisterItemViewModel {
    
    func updateTitle() {
        title = model?.title ?? ""
    }
    
    func updateOverview() {
        overview = model?.overview ?? ""
    }
    
    func updateRating() {
        rating = movie.rating == 0 ? "My Rating:" : String(format: "My Rating: %.1f", 0.1 * Double(movie.rating))
    }
    
    func updateMovieModel() {
        
        
    }
}

