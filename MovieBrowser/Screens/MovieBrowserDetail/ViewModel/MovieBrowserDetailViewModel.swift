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

///
/// View-model class for the Movie Browser screen view
///
class MovieBrowserDetailViewModel: ObservableObject, ViewLifeCycleEvents, DBContext {
 
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
        
        updateImage()
        updateGenres()
        updateMovie()
        updateSaved()
    
        appeared = true
    }
    
    func onDisappear() { }
    
    init(model: MovieModel, api: MovieAPI, moc: NSManagedObjectContext) {
        
        print("\(type(of: self)) - init \(model.id)")
        
        self.model = model
        self.api = api
        self.moc = moc
        
        title = model.title ?? ""
        releaseDate = model.releaseDate ?? ""
        overview = model.overview ?? ""
        genres = ""
        averageVote = model.voteAverage == nil ? nil : String(format:"%.1f", model.voteAverage!)
        saved = false
    }
    
    deinit {
        print("\(type(of: self)) - deinit \(model.id)")
    }
    
    private let model: MovieModel
    var moc: NSManagedObjectContext
    private let api: MovieAPI

    private var appeared = false
    private var cancellableImage: AnyCancellable?
    private var cancellableGenres: AnyCancellable?
    private var movie: DBMovie?
}

extension MovieBrowserDetailViewModel {
    
    func storeError(_ error: Error) {
        self.error = error.localizedDescription
        assert(false)
    }
}

extension MovieBrowserDetailViewModel {
    
    private func didSetSaved(_ save: Bool) {
        
        if movie == nil {
            
            if save {
                movie = DBMovie.create(moc)
                movie!.tmdbId = Int32(model.id)
                storeSave()
            }
        }
        else {
            
            if !save {
                moc.delete(movie!)
                storeSave()
            }
        }
    }
    
    private func updateSaved() {
        saved = movie != nil
    }
}

extension MovieBrowserDetailViewModel {
    
    private func updateMovie() {
        
        do {
            movie = try DBMovie.fetchMovieWithId(id: Int32(model.id), moc:moc)
        }
        catch {
            storeError(error)
        }
    }
    
    private func updateImage() {

        guard let posterPath = model.posterPath else {
           return
        }

        cancellableImage = api.mediaObject(path:posterPath, size:nil, type:.JPG).sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.error = error.localizedDescription
                    assert(false)
                }
            },
            receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.posterImage = value
            })
    }
    
    private func updateGenres() {

        guard let genreIds = model.genres, !genreIds.isEmpty else {
           return
        }
        
        cancellableGenres = api.movieGenres().sink(
            receiveCompletion: { completion in
                if case .failure = completion { assert(false) }
            },
            receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.initGenres(map:value)
            })
    }
    
    /// Converts the object's genre ids to string representation using the provided map
    private func initGenres(map:[GenreModel]) {
        
        guard let genreIds = model.genres, !genreIds.isEmpty else {
           return
        }
        
        genres = ""
        
        for id in genreIds {
            
            if let name = map.first(where: { $0.id == id })?.name {
                genres += name + ", "
            }
        }
        
        genres = String(genres.dropLast(2))
    }
}
