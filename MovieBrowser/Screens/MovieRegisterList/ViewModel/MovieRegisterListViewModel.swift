//
//  MovieRegisterListViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 12/07/2021.
//

import Foundation
import SwiftUI
import Combine
import CoreData
import Reusable
import MovieBEService

///
///
///
class MovieRegisterListViewModel: ObservableObject, ViewLifeCycleEvents, DBContext, MovieServiceDetailDelegate {

    @Published var error: String?
    
    @Published var movies: [MovieRegisterItemViewModel] = []
    
    func onAppear() {
        
        sortMovies()
        
         guard !appeared else {
             return
         }

        updateMovies()
    
        appeared = true
    }
    
    func onDisappear() {
    }
    
    init(moc: NSManagedObjectContext, movieService: MovieService) {
        
        print("\(type(of: self)) - init")
        
        self.moc = moc
        self.movieService = movieService
        
        self.movieService.detailDelegate = self
    }
    
    deinit {
        print("\(type(of: self)) - deinit")
    }
    
    var moc: NSManagedObjectContext
    
    private var movieService: MovieService
    private var appeared = false
}

extension MovieRegisterListViewModel {
    
    func updateMovies() {

        do {
            
            movies = try DBObjects.fetchAll(moc:moc).map( { MovieRegisterItemViewModel(movie:$0!, service:movieService) } )
            
            sortMovies()
        }
        catch {
            
            self.error = error.localizedDescription
        }
    }
    
    func sortMovies() {
        movies.sort(by: { $0.registeredMovie.rating > $1.registeredMovie.rating })
    }
}


extension MovieRegisterListViewModel {
    
    func deleteMovies(at indexes: IndexSet) {
        
        var deleted = [MovieRegisterItemViewModel]()
        
        for index in indexes {
            deleted.append(movies[index])
        }
        
        for movie in deleted {
            let obj = movies.remove(at:movies.firstIndex(of:movie)!)
            moc.delete(obj.registeredMovie)
        }
        
        storeSave()
    }
}

///
/// MovieServiceDetailDelegate conformance
///
extension MovieRegisterListViewModel {
    
    func movieDetail(model: MovieDetailModel) {
        if let movie = movies.first(where: { $0.id == model.id }) {
            movie.updateModel(model: model)
        }
    }
    
    func error(_: MovieServiceError) {
    }
}

///
/// DBContext conformance
///
extension MovieRegisterListViewModel {
    
    func storeError(_ error: Error) {
        self.error = error.localizedDescription
        assert(false)
    }
}


