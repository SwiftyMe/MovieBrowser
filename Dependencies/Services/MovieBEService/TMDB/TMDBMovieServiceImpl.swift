//
//  TMDBMovieBEServiceImpl.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 25/07/2021.
//

import Foundation
import Combine
import UIKit

public class MovieServiceImplementation: MovieService {
    
    public var detailDelegate: MovieServiceDetailDelegate?
    
    public var browseDelegate: MovieServiceBrowseDelegate?

    public var allGenres: [MovieGenre] = [] {
        didSet {
            browseDelegate?.genresUpdated()
        }
    }
    
    public init() {
        
        self.api = TMDBMovieAPIImpl()
        
        fetchGenreFilter()
    }
    
    private let api: TMDBMovieAPIImpl
    
    private var list: MovieList = .popular
    
    private var page = Int(0)
    private var pageMax: Int?
    private var pageSize: Int?

    private var pageCompletions: [Int:PageCompletion] = [:]
    private var genresCancellable: AnyCancellable?
    
    private var ids: [Int:Bool] = [:]
    
    private var maxVisible: (Int,Int)? = nil
    private var posterImagesCancellables: [Int:AnyCancellable] = [:]
    private var movieDetailCancellables: [Int:AnyCancellable] = [:]
    
    private var genreMap: [Int:MovieGenre] = [:]
    
    private var movieDetailModels: [Int:MovieDetailModel] = [:]
    
    private let genresSemaphore = DispatchSemaphore(value: 0)
}


extension MovieServiceImplementation {
    
    public func fetchItems(list: MovieList) {
        
        self.list = list
        
        clear()
        
        addPage()
    }
    
    public func fetchDetailModel(model: MovieModel) {
        
        if let tmdbModel = movieModel(id: model.id), let posterPath = tmdbModel.posterPath, let delegate = detailDelegate {
            
            posterImagesCancellables[model.id] = api.mediaObject(path:posterPath, size:400, type:.JPG)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] value in
                    guard let self = self else { return }
                    delegate.movieDetail(model: MovieDetailModel(model, posterImage:value))
                    self.posterImagesCancellables[model.id] = nil
                })
        }
    }
    
    public func fetchDetailModel(id: Int) {
        
        guard let delegate = detailDelegate else { return }
        
        if let detailModel = self.movieDetailModels[id] {
            delegate.movieDetail(model:detailModel)
            return
        }
        
        if let tmdbModel = movieModel(id: id) {
            
            if let posterPath = tmdbModel.posterPath {
                
                posterImagesCancellables[id] = api.mediaObject(path:posterPath, size:400, type:.JPG)
                    .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] value in
                        guard let self = self else { return }
                        let model = MovieModel(tmdbModel:tmdbModel, genres: self.genremap(ids:tmdbModel.genres ?? []))
                        self.movieDetailModels[id] = MovieDetailModel(model, posterImage:value)
                        delegate.movieDetail(model: self.movieDetailModels[id]!)
                        self.posterImagesCancellables[id] = nil
                    })
            }
        }
        else {
            
            movieDetailCancellables[id] = api.movieDetail(id:id)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] detailModel in
                    guard let self = self else { return }
                    self.movieDetailCancellables[id] = nil
                    if let posterPath = detailModel.posterPath {
                        self.posterImagesCancellables[id] = self.api.mediaObject(path:posterPath, size:400, type:.JPG)
                            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] posterImage in
                                guard let self = self else { return }
                                let model = MovieDetailModel(tmdbModel: detailModel, genres: self.genremap(ids:detailModel.genres ?? []), posterImage: posterImage)
                                self.movieDetailModels[id] = model
                                delegate.movieDetail(model:self.movieDetailModels[id]!)
                                self.posterImagesCancellables[id] = nil
                            })
                    }
                })
        }
    }
    
    public func updateModel(model: MovieModel) {
        
        if let tmdbModel = movieModel(id: model.id), let posterPath = tmdbModel.posterPath, let delegate = browseDelegate {
            
            posterImagesCancellables[model.id] = api.mediaObject(path:posterPath, size:200, type:.JPG)
                .sink(receiveCompletion: { [weak self] _ in
                    self?.posterImagesCancellables[model.id] = nil
                }, receiveValue: { value in
                    var model = model
                    model.posterImage = value
                    delegate.updateModel(model: model)
                })
        }
    }
    
    public func itemBecameVisible(id: Int) {
        
        print("itemBecameVisible \(id)")
        
        guard let pageSize = pageSize else {
            return
        }
        
        for (pageIndex,page) in pageCompletions.filter({ $0.value.send }).enumerated() {
            
            if let movieIndex = page.value.movies.firstIndex(where: { $0.id == id }) {
                
                if maxVisible == nil {
                    maxVisible = (movieIndex,pageIndex)
                }
                else {
                    
                    let u = maxVisible!.0 + maxVisible!.1 * pageSize
                    let y = movieIndex + pageIndex * pageSize
                    
                    maxVisible = u < y ? (movieIndex,pageIndex) : maxVisible
                }
            }
        }
        
        if let maxVisible = maxVisible {
            
            let position = maxVisible.0 + maxVisible.1 * pageSize
            let threshold = 0.75 * Double(page * pageSize)
            
            if Double(position) > threshold {
                addPage()
            }
        }
    }
}

extension MovieServiceImplementation {
    
    private func addPage() {
        
        page += 1
        fetchMovies()
    }
    
    private func clear() {
        
        page = 0
        
        maxVisible = nil
        
        pageCompletions.forEach( { $0.value.cancel() } )
        
        pageCompletions.removeAll()
        
        ids.removeAll()
        
        posterImagesCancellables.removeAll()
    }
    
    private func fetchMovies() {
        
        let receiveCompletion: (Subscribers.Completion<MovieAPIError>) -> Void = { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .failure(let error):
                self.pageCompletions.removeAll()
            case .finished:
                break
            }
        }
        
        let receiveValue: (TMDBMoviesModel) -> Void = { [weak self] value in
            
            guard let self = self, let _ = self.browseDelegate else { return }
            
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
            
            completion.movies = value.results ?? []
            
            if self.genreMap.isEmpty {
                self.genresSemaphore.wait()
            }

            completion.finalizePage()
            
            self.sendNewMovies()
        }
        
        var publisher: AnyPublisher<TMDBMoviesModel,MovieAPIError>!
        
        switch list {
            case .popular: publisher = api.MovieBrowser(page:page)
            case .topRated: publisher = api.topRatedMovies(page:page)
            case .upComing: publisher = api.upComingMovies(page:page)
        }
        
        let cancellable = publisher
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
        
        pageCompletions[page] = PageCompletion(cancellable: cancellable)
    }
    
    private func sendNewMovies() {

        var newMovies = [MovieModel]()
        
        for page in pageCompletions.values {
            
            if !page.finalized { break }
            
            /// The test below is necassary since some movies appear more than once (?).
            /// If duplicates are not prevented, SwiftUI may crash.
            
            let movies = page.movies
                .filter({ let ret = ids[$0.id] == nil; ids[$0.id] = true; return ret })
                .map({ MovieModel(tmdbModel:$0, genres: genremap(ids:$0.genres ?? [])) })
            
            newMovies.append(contentsOf:movies)
            
            page.send = true
        }
        
        print("sendNewMovies count = \(newMovies.count)")
        
        browseDelegate?.newMovies(list: self.list, models: newMovies)
    }
    
    private func fetchGenreFilter() {
        
        genreMap.removeAll()
        allGenres.removeAll()
        
        genresCancellable = api.movieGenres()
            // .delay(for: 5, scheduler: DispatchQueue.global())
            .sink(
            receiveCompletion: { completion in
                if case .failure = completion { assert(false) }
            },
            receiveValue: { [weak self] value in
                guard let self = self else { return }
                value.forEach({
                    if let movieGenre = MovieGenre(tmdbGenre: $0) {
                        self.genreMap[$0.id] = movieGenre
                    }
                })

                self.genresSemaphore.signal()

                DispatchQueue.main.async {
                    self.allGenres = self.genreMap.values.compactMap({ $0 }).sorted(by: { $0.description < $1.description })
                }
            })
    }
}

///
/// Utility
///
extension MovieServiceImplementation {
    
    
    private func genremap(ids:[Int]) -> [MovieGenre] {
        ids.compactMap({ genreMap[$0] })
    }
    
    private func genremap(ids:[TMDBGenreModel]) -> [MovieGenre] {
        ids.compactMap({ genreMap[$0.id] })
    }
    
    private func movieModel(id: Int) -> TMDBMovieModel? {
        
        for page in pageCompletions.values {
            
            if let movie = page.movies.first(where:{ $0.id == id }) {
                return movie
            }
        }
        
        return nil
    }
}


extension MovieServiceImplementation {
    
    class PageCompletion {
        
        init(cancellable: AnyCancellable) {
            self.cancellable = cancellable
        }
        
        var send: Bool = false
        var movies: [TMDBMovieModel] = []
        
        private var cancellable: AnyCancellable?
        private var itemCancellables: [Int:AnyCancellable] = [:]
        
        var finalized: Bool {
            cancellable == nil
        }
        
        func finalizePage() {
            cancellable = nil
            assert(Thread.current.isMainThread)
        }
        
        func storePageItem(item: Int, cancellable: AnyCancellable) {
            itemCancellables[item] = nil
        }
        
        func finalizePageItem(item: Int) {
            itemCancellables[item] = nil
        }
        
        func cancel() {
            cancellable?.cancel()
        }
    }
}



extension MovieModel {
    
    init(tmdbModel: TMDBMovieModel, genres: [MovieGenre] = [], posterImage: UIImage? = nil) {
        
        id = tmdbModel.id
        self.posterImage = posterImage
        title = tmdbModel.title ?? ""
        overview = tmdbModel.overview ?? ""
        releaseDate = tmdbModel.releaseDate
        voteAverage = tmdbModel.voteAverage
        self.genres = genres
    }
}

extension MovieDetailModel {
    
    init(tmdbModel: TMDBMovieDetailModel, genres: [MovieGenre] = [], posterImage: UIImage? = nil) {
        
        id = tmdbModel.id
        self.posterImage = posterImage
        title = tmdbModel.title ?? ""
        overview = tmdbModel.overview ?? ""
        releaseDate = tmdbModel.releaseDate
        voteAverage = tmdbModel.voteAverage
        self.genres = genres
    }
}


extension MovieGenre {
    
    init?(tmdbGenre: TMDBGenreModel) {
        
        guard let name = tmdbGenre.name else {
            return nil
        }
        
        let genreName = name.lowercased()

        for genre in MovieGenre.allCases {
            
            if genre.description.lowercased() == genreName {
                self = genre
                return
            }
        }
        
        self = .other(genreName)
    }
}


