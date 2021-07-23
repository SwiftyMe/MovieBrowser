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

///
///
///
class MovieRegisterListViewModel: ObservableObject, ViewLifeCycleEvents, DBContext {

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
    
    init(moc: NSManagedObjectContext, api: MovieAPI) {
        
        self.moc = moc
        self.api = api
    }
    
    var moc: NSManagedObjectContext
    
    private let api: MovieAPI
    private var appeared = false
}

extension MovieRegisterListViewModel {
    
    func updateMovies() {

        do {
            
            movies = try DBObjects.fetchAll(moc:moc).map( { MovieRegisterItemViewModel(movie:$0!, api:api) } )
            
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


extension MovieRegisterListViewModel {
    
    func storeError(_ error: Error) {
        self.error = error.localizedDescription
        assert(false)
    }
}


