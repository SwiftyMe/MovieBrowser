//
//  MovieBrowserListViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import Foundation
import SwiftUI
import Combine
import Reusable
import MovieBEService

///
/// View-model class for the Movie Browser screen view
///
class MovieBrowserListViewModel: ObservableObject, MovieServiceBrowseDelegate {
    
    let scrollToTop = PassthroughSubject<Int,Never>()
    
    @Published var error: String?
    
    @Published var searchText: String = "" {
        didSet {
            search()
        }
    }
    
    @Published var movieList = MovieList.topRated {
        didSet {
            fetchMovies()
        }
    }
    
    @Published var movies: [MovieBrowserItemViewModel] = []
    
    @Published var genreFilter: [GenreFilterItemViewModel] = []
    
    func onAppear() {
        
        guard !appeared else {
            return
        }
        
        fetchMovies()
        
        appeared = true
    }
    
    func onDisappear() { }
    
    init(service: MovieService) {

        movieService = service
        movieService.browseDelegate = self
    }

    private var movieService: MovieService
    private var savedMovies: [MovieBrowserItemViewModel] = []
    private var visibleChangedCancellables: [Int:AnyCancellable] = [:]
    
    private var appeared = false
    private var waitForVisible = false
}

/// Conformance to MovieServiceBrowseDelegate
///
///
extension MovieBrowserListViewModel {
    
    func newMovies(list: MovieList, models: [MovieModel]) {

        for model in models {
            
            let item = MovieBrowserItemViewModel(model:model, service:movieService)
            
            savedMovies.append(item)
            
            visibleChangedCancellables[model.id] = item.visibleChanged.sink(receiveValue: {
                item in self.itemVisibleChanged(item:item)
            })
        }
        
        filterMovies()
    }
    
    func genresUpdated() {
        
        createGenreFilter()
    }
    
    func error(_ error: MovieServiceError) {
        
        self.error = error.localizedDescription
    }
}


extension MovieBrowserListViewModel {

    /// Likely called on dismiss from view
    func updateGenreFilter() {
        
        var saved = [String]()
        
        for filter in genreFilter {
            
            if !filter.included {
                saved.append(filter.name)
            }
        }
        
        UserDefaults.standard.set(saved, forKey: UserDefaults.genres)
        
        filterMovies()
    }
    
    func genreFilterSelectAll() {
        
        genreFilter.forEach( { $0.included = true })
    }
    
    func genreFilterDeselectAll() {
        
        genreFilter.forEach( { $0.included = false })
    }
}


extension MovieBrowserListViewModel {
    
    private func search() {
        
        filterMovies()
    }

    private func fetchMovies() {
        
        savedMovies.removeAll()
        
        switch movieList {
            case .popular: movieService.fetchItems(list:.popular)
            case .topRated: movieService.fetchItems(list:.topRated)
            case .upComing: movieService.fetchItems(list:.upComing)
        }
    }

    private func itemVisibleChanged(item: MovieBrowserItemViewModel) {

        if waitForVisible {
            
            // FIXME: Scroll to top is send for all items becoming visible. Initially the idea was to
            // detect when the first item in the list was becoming visible and then send scrollToTop.
            // However this is not possible as there is no ensurance for the item to become visible as it
            // may already be visible (if it existed previously - in another list).
            
            if let id = movies.first?.id, item.visible {
                waitForVisible = false
                
                scrollToTop.send(id)
            }
        }
        
        if item.visible && searchText.isEmpty {
            
            movieService.itemBecameVisible(id: item.id)
        }
    }

    private func createGenreFilter() {
        
        genreFilter = movieService.allGenres.map( { .init(model: $0.description, isIncluded: true) })
        
        if let saved = UserDefaults.standard.array(forKey:UserDefaults.genres) as? [String] {
            
            for filter in genreFilter {
                
                if saved.contains(filter.name) {
                    filter.included = false
                }
            }
        }
    }
    
    private func filterMovies() {
        
        if searchText.isEmpty {
            
            movies = savedMovies
        }
        else {
            
            movies = savedMovies.filter( { $0.title.lowercased().contains(searchText.lowercased()) } )
        }

        let filters = genreFilter.filter { filter in !filter.included }
        
        if !filters.isEmpty {
            
            let filter = filters.map( { $0.name })
            
            movies = movies.filter({ $0.modelObject.genres.allSatisfy({ !filter.contains($0.description) }) } )
        }
    }
}




