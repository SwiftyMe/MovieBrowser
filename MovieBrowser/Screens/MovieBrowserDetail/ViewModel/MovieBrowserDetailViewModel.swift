//
//  File.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import Foundation
import SwiftUI
import Combine
import CoreData
import Reusable
import MovieBEService

///
/// View-model class for the Movie Browser screen view
///
class MovieBrowserDetailViewModel: ObservableObject, ViewLifeCycleEvents, DBContext, MovieServiceDetailDelegate {

    @Published var error: String?
    
    let title: String
    let releaseDate: String
    let overview: String
    let averageVote: String?
    
    @Published var genres: String
    @Published var posterImage: UIImage?
    
    @Published var saved: Bool {
        didSet {
            didSetSaved(saved)
        }
    }
    
    func onAppear() {
        
        assert(!appeared)
        
        guard !appeared else {
            return
        }
        
        fetchModelDetail()
    
        appeared = true
    }
    
    func onDisappear() { }
    
    init(model: MovieModel, movieService: MovieService, moc: NSManagedObjectContext) {
        
        print("\(type(of: self)) - init \(model.id)")
        
        self.model = model
        self.movieService = movieService
        self.moc = moc
        
        title = model.title
        releaseDate = model.releaseDate ?? ""
        overview = model.overview
        genres = model.genres.map({ $0.description }).joined(separator:", ")
        averageVote = model.voteAverage == nil ? nil : String(format:"%.1f", model.voteAverage!)
        saved = false
        modelDetail = nil
        
        self.movieService.detailDelegate = self
        
        updateRegisteredMovie()
        updatePropertySaved()
        
        print(self.genres)
    }
    
    deinit {
        print("\(type(of: self)) - deinit \(model.id)")
    }
    
    var moc: NSManagedObjectContext
    
    private let model: MovieModel
    private var movieService: MovieService
    private var modelDetail: MovieDetailModel?
    private var registeredMovie: DBMovie?
    private var appeared = false
}

extension MovieBrowserDetailViewModel {
    
    func storeError(_ error: Error) {
        self.error = error.localizedDescription
        assert(false)
    }
}

extension MovieBrowserDetailViewModel {
    
    private func didSetSaved(_ save: Bool) {
        
        if registeredMovie == nil {
            
            if save {
                registeredMovie = DBMovie.create(moc)
                registeredMovie!.tmdbId = Int32(model.id)
                storeSave()
            }
        }
        else {
            
            if !save {
                moc.delete(registeredMovie!)
                storeSave()
            }
        }
    }
    
    private func updatePropertySaved() {
        saved = registeredMovie != nil
    }
}

extension MovieBrowserDetailViewModel {
    

    private func updateRegisteredMovie() {
        
        do {
            registeredMovie = try DBMovie.fetchMovieWithId(id: Int32(model.id), moc:moc)
        }
        catch {
            storeError(error)
        }
    }
    
    private func updatePropertyImage() {
        
        posterImage = modelDetail?.posterImage
    }
    
    private func updatePropertyGenres() {
        
    }
    
    private func fetchModelDetail() {
        
        movieService.fetchDetailModel(model: model)
    }
}


extension MovieBrowserDetailViewModel {
    
    func movieDetail(model: MovieDetailModel) {
        
        modelDetail = model
        
        updatePropertyImage()
        updatePropertyGenres()
    }
    
    func error(_: MovieServiceError) {
        
    }
}
