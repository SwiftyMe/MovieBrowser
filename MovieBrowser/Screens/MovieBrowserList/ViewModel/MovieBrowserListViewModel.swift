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

///
/// View-model class for the Movie Browser screen view
///
class MovieBrowserListViewModel: ObservableObject {
    
    enum MovieList: Int, CaseIterable { case popular, topRated, upComing }
    
    let scrollToTop = PassthroughSubject<Int,Never>()
    
    @Published var error: String?
    
    @Published var searchText: String = "" {
        didSet {
            search()
        }
    }
    
    @Published var movieList = MovieList.topRated {
        didSet {
            changeList()
        }
    }
    
    @Published var movies: [MovieBrowserItemViewModel] = []
    
    @Published var genreFilter: [GenreFilterItemViewModel] = []
    
    func onAppear() { }
    func onDisappear() { }
    
    init(api: MovieAPI) {

        self.api = api
        
        addPage()
        addPage()
        
        createGenreFilter()
    }

    private let api: MovieAPI
    
    private var page = Int(0)
    private var pageMax: Int?
    private var pageSize: Int?
    private var waitForVisible = false
    private var savedMovies: [MovieBrowserItemViewModel] = []
    private var appeared = false
    
    private var pageCompletions: [Int:PageCompletion] = [:]
    private var cancellableGenres: AnyCancellable?
}

extension MovieBrowserListViewModel {
    
    class PageCompletion {
        
        init(cancellable: AnyCancellable) {
            self.cancellable = cancellable
        }
        
        private var cancellable: AnyCancellable?
        private var itemCancellables: [Int:AnyCancellable] = [:]
        
        var finalized: Bool {
            cancellable == nil
        }
        
        func finalizePage() {
            cancellable = nil
        }
        
        func storePageItem(item: Int, cancellable: AnyCancellable) {
            itemCancellables[item] = nil
        }
        
        func finalizePageItem(item: Int) {
            itemCancellables[item] = nil
        }
    }
}


extension MovieBrowserListViewModel {
    
    private func search() {
        
        filterMovies()
    }
    
    private func addPage() {
        
        page += 1
        fetchMovies()
    }

    private func changeList() {
        
        waitForVisible = true
        
        clear()
        
        addPage()
        addPage()
    }
    
    private func clear() {
        
        page = 0
        savedMovies.removeAll()
    }

    private func fetchMovies() {
        
        let receiveCompletion: (Subscribers.Completion<MovieAPIError>) -> Void = { [weak self] completion in
            guard let self = self else { return }
            switch completion {
                case .failure(let error):
                    self.error = error.localizedDescription
                    self.savedMovies = []
                    self.pageCompletions.removeAll()
                case .finished:
                    self.error = nil
            }
        }
        
        let receiveValue: (MoviesModel) -> Void = { [weak self] value in

            guard let self = self else { return }
            
            guard let page = value.page, let results = value.results, let totalPages = value.totalPages else {
                assert(false)
                return
            }
            guard let completion = self.pageCompletions[page] else {
                assert(false)
                return
            }

            self.pageMax = totalPages
            self.pageSize = results.count
            
            let count = self.pageCompletions.reduce(0) { $0 + (($1.key < page && $1.value.finalized) ? 1 : 0) }

            var offset = self.pageSize! * count
            
            for model in (value.results!) {
                
                if !self.savedMovies.contains(where: { $0.id == model.id }) {
                    
                    /// The test is necassary since some movies actually appear more than once. If duplicates are not
                    /// prevented, SwiftUI will crash if the same items appear (visible) in the list (tested by making a search
                    /// on duplicated movies).
                    
                    let item = MovieBrowserItemViewModel(model:model, api:self.api)
                    self.savedMovies.insert(item, at: offset)
                    
                    let cancellable = item.visibleChanged.sink(receiveValue: {
                        item in self.itemVisibleChanged(item:item)
                        completion.finalizePageItem(item: item.id)
                    })
                    
                    completion.storePageItem(item: item.id, cancellable: cancellable)
                    
                    offset += 1
                }
            }
            
            completion.finalizePage()
            
            self.filterMovies()
        }
        
        var cancellable: AnyCancellable?

        switch movieList {
            case .popular:
                cancellable = api.MovieBrowser(page:page)
                    .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
            case .topRated:
                cancellable = api.topRatedMovies(page:page)
                    .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
            case .upComing:
                cancellable = api.upComingMovies(page:page)
                    .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
        }
        
        pageCompletions[page] = PageCompletion(cancellable: cancellable!)
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
        
        if item.visible && !searchText.isEmpty {
            updateContinuousPagination(item:item)
        }
    }
    
    ///
    ///
    ///
    private func updateContinuousPagination(item:MovieBrowserItemViewModel) {

        guard let pageMax = pageMax, let pageSize = pageSize, page < pageMax, !searchText.isEmpty else {
            return
        }

        let delta = max(pageSize/4,1)
        
        if movies.isThresholdItem(delta:delta, item:item) {
            addPage()
        }
    }
    
    private func createGenreFilter() {

        cancellableGenres = api.movieGenres().sink(
            receiveCompletion: { completion in
                if case .failure = completion { assert(false) }
            },
            receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.createGenreFilter(genres: value)
            })
    }
    
    private func createGenreFilter(genres:[GenreModel]) {
        
        genreFilter.removeAll()
        
        genreFilter = genres.map( { .init(model: $0) })
        
        if let saved = UserDefaults.standard.array(forKey:UserDefaults.genres) as? [Int] {
            
            for filter in genreFilter {
                
                if saved.contains(where: { $0 == filter.id } ) {
                    filter.included = false
                }
            }
        }
    }
    
    func updateGenreFilter() {
        
        var saved = [Int]()
        
        for filter in genreFilter {
            
            if !filter.included {
                saved.append(filter.id)
            }
        }
        
        UserDefaults.standard.set(saved, forKey: UserDefaults.genres)
        
        filterMovies()
    }
    
    func genreFilterSelectAll() {
        
        for filter in genreFilter {
            filter.included = true
        }
    }
    
    func genreFilterDeselectAll() {
        
        for filter in genreFilter {
            filter.included = false
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
            
            let filter = filters.map( { $0.id })
            
            movies = movies.filter({ $0.modelObject.genres!.allSatisfy({ !filter.contains($0) }) } )
        }
    }
}




