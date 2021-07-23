//
//  MovieRegisterDetailViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 17/07/2021.
//

import Foundation
import SwiftUI
import Combine
import CoreData
import Reusable

///
///
///
class MovieRegisterDetailViewModel: ObservableObject, ViewLifeCycleEvents, DBContext {

    @Published var error: String?
    
    let title: String
    let releaseDate: String
    let overview: String
    let averageVote: String?
    var genres: String
    
    @Published var posterImage: UIImage?
    
    @Published var rating: Double = 0 {
        didSet {
            updateModelRating()
        }
    }
    
    @Published var notes: [MovieNoteItemViewModel] = []

    func onAppear() {
        
        updatePropertyNotes()
        
        guard !appeared else {
            storeSave()
            return
        }

        print("MovieRegisterDetailViewModel - onAppear \(movie.tmdbId)")

        updatePropertyImage()

        appeared = true
    }
    
    func onDisappear() {
        
        storeSave()

        print("MovieRegisterDetailViewModel - onDisappear \(movie.tmdbId)")
    }
    
    @discardableResult
    func addNote() ->  MovieNoteItemViewModel {
        
        let note = DBNote.create(moc)
        
        note.movie = movie
        
        let item = MovieNoteItemViewModel(note: note)
        
        notes.append(item)
        
        storeSave()
        
        return item
    }
    
    init(movie: DBMovie, model: MovieDetailModel, api: MovieAPI) {
        
        print("MovieRegisterDetailViewModel - init \(movie.tmdbId)")
        
        self.movie = movie
        self.model = model
        self.api = api
        self.moc = movie.managedObjectContext!

        title = model.title ?? ""
        releaseDate = model.releaseDate ?? ""
        overview = model.overview ?? ""
        genres = ""
        averageVote = model.voteAverage == nil ? nil : String(format:"%.1f", model.voteAverage!)
        
        updatePropertyGenres()
        updatePropertyRating()
        updatePropertyNotes()
    }
    
    deinit {
        print("MovieRegisterDetailViewModel - deinit \(movie.tmdbId)")
    }
    
    var moc: NSManagedObjectContext
    
    private var movie: DBMovie
    private let model: MovieDetailModel

    private let api: MovieAPI
    private var appeared = false
    private var cancellableImage: AnyCancellable?
}

extension MovieRegisterDetailViewModel {
    
    func storeError(_ error: Error) {
        self.error = error.localizedDescription
        assert(false)
    }
}

extension MovieRegisterDetailViewModel {
    
    func deleteMovies(at indexes: IndexSet) {
        
        var deleted = [MovieNoteItemViewModel]()
        
        for index in indexes {
            deleted.append(notes[index])
        }
        
        for movie in deleted {
            let obj = notes.remove(at:notes.firstIndex(of:movie)!)
            moc.delete(obj.modelObject)
        }
        
        storeSave()
    }
}

extension MovieRegisterDetailViewModel {
    
    private func updatePropertyImage() {

        guard let posterPath = model.posterPath else {
           return
        }

        cancellableImage = api.mediaObject(path:posterPath, size:nil, type:.JPG)
            .sink(receiveCompletion: { [weak self] completion in
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
    
    func updatePropertyRating() {
        rating = Double(movie.rating)
    }
    
    func updateModelRating() {
        movie.rating = Int16(rating)
    }
    
    func updatePropertyGenres() {
        
        var genreNames = ""
        
        for genre in model.genres ?? [] where genre.name != nil && !genre.name!.isEmpty {
            genreNames += genre.name! + ", "
        }
        
        genres = String(genreNames.dropLast(2))
    }
    
    func updatePropertyNotes() {

        notes.removeAll()
        
        for note in movie.notes {
            
            if let model = note as? DBNote {
                
                notes.append(MovieNoteItemViewModel(note:model))
            }
        }
        
        notes.sort(by: { $0.created > $1.created })
    }
}

