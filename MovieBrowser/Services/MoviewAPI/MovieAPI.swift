//
//  MovieAPI.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import Foundation
import UIKit
import Combine

/// enum used in protocol MovieAPI
enum MediaObjectType {
    case SVG, PNG, JPG
}

///
/// API Errors, related to the MovieAPI protocol
///
/// - Note: See extension below for more description of errors
///
enum MovieAPIError: Swift.Error {
    
    case HTTPGetRequest(Error)
    case InvalidParameter(String)
    case MediaObjectLoad(String)
    case ImageCouldInitialize
}

///
/// The MovieAPI protocol, a high level interface for accessing the Movie Database API
///
protocol MovieAPI {
    
    func movieDetail(id:Int) -> AnyPublisher<MovieDetailModel, MovieAPIError>
    
    func MovieBrowser() -> AnyPublisher<[MovieModel],MovieAPIError>
    
    func MovieBrowser(page:Int) -> AnyPublisher<MoviesModel,MovieAPIError>
    func topRatedMovies(page:Int) -> AnyPublisher<MoviesModel,MovieAPIError>
    func upComingMovies(page:Int) -> AnyPublisher<MoviesModel,MovieAPIError>

    func movieGenres() -> AnyPublisher<[GenreModel],MovieAPIError>
    
    func mediaObject(path:String, size:Int?, type:MediaObjectType) -> AnyPublisher<UIImage,MovieAPIError>
}

///
/// Implementation of the MovieAPI protocol
///
class MovieAPIImpl: MovieAPI {
    
    /// Retrieves details for a movie id
    func movieDetail(id:Int) -> AnyPublisher<MovieDetailModel, MovieAPIError> {
        
        let request = Self.URLRequest(url:Self.URL(apiurl:"https://api.themoviedb.org/3/movie/"+String(id)))

        return HTTPService.urlRequest(request)
            .mapError { error -> MovieAPIError in .HTTPGetRequest(error) }
            .receive(on:RunLoop.main)
            .eraseToAnyPublisher()
    }
    

    /// Retrieves popular movies
    ///
    /// This version only retrieve page 1 in a paginated list
    func MovieBrowser() -> AnyPublisher<[MovieModel], MovieAPIError> {
        
        let request = Self.URLRequest(url:Self.URL(apiurl:"https://api.themoviedb.org/3/movie/popular"))
        
        return HTTPService.urlRequest(request)
            .map { (movies:MoviesModel) -> [MovieModel]?  in  movies.results }
            .replaceNil(with:[])
            .mapError { error -> MovieAPIError in .HTTPGetRequest(error) }
            .receive(on:RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    /// Retrieves popular movies
    ///
    /// - Parameters
    ///   - page: the movie list is paginated. A page number can be specified starting from 1.
    func MovieBrowser(page:Int) -> AnyPublisher<MoviesModel,MovieAPIError> {
        
        if page < 1 {
            return Fail<MoviesModel, MovieAPIError>(error:.InvalidParameter("page parameter is less than 1"))
                .eraseToAnyPublisher()
        }
        
        let url = Self.URL(apiurl:"https://api.themoviedb.org/3/movie/popular", page:page)
        
        let request = Self.URLRequest(url:url)
        
        return HTTPService.urlRequest(request)
            .mapError { error -> MovieAPIError in .HTTPGetRequest(error) }
            .receive(on:RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    /// Retrieves top-rated movies
    ///
    /// - Note: see doc in popular movies
    func topRatedMovies(page:Int) -> AnyPublisher<MoviesModel,MovieAPIError> {
        
        if page < 1 {
            return Fail<MoviesModel, MovieAPIError>(error:.InvalidParameter("page parameter is less than 1"))
                .eraseToAnyPublisher()
        }
        
        let url = Self.URL(apiurl:"https://api.themoviedb.org/3/movie/top_rated", page:page)
        
        let request = Self.URLRequest(url:url)

        return HTTPService.urlRequest(request)
            .mapError { error -> MovieAPIError in .HTTPGetRequest(error) }
            .receive(on:RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    /// Retrieves top-rated movies
    ///
    /// - Note: see doc in popular movies
    func upComingMovies(page:Int) -> AnyPublisher<MoviesModel,MovieAPIError> {
        
        if page < 1 {
            return Fail<MoviesModel, MovieAPIError>(error:.InvalidParameter("page parameter is less than 1"))
                .eraseToAnyPublisher()
        }
        
        let url = Self.URL(apiurl:"https://api.themoviedb.org/3/movie/upcoming", page:page)
        
        let request = Self.URLRequest(url:url)
        
        return HTTPService.urlRequest(request)
            .mapError { error -> MovieAPIError in .HTTPGetRequest(error) }
            .receive(on:RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    ///
    /// Retrieves movie genres in the database
    ///
    func movieGenres() -> AnyPublisher<[GenreModel],MovieAPIError> {
        
        let url = Self.URL(apiurl:"https://api.themoviedb.org/3/genre/movie/list")
        
        let request = Self.URLRequest(url:url)
        
        return HTTPService.urlRequest(request)
            .map { (genres:GenresModel) -> [GenreModel]?  in  genres.genres }
            .replaceNil(with:[])
            .mapError { error -> MovieAPIError in .HTTPGetRequest(error) }
            .receive(on:RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    ///
    /// Retrieve a media object (poster image)
    ///
    /// - Note: type parameter has not been tested for other than JPG
    ///
    func mediaObject(path:String, size:Int?, type:MediaObjectType) -> AnyPublisher<UIImage, MovieAPIError> {
        
        if type == .SVG && size != nil {

            return Fail<UIImage, MovieAPIError>(error:.InvalidParameter("SVG format does not allow resizing"))
                .eraseToAnyPublisher()
        }
        
        var newpath = path
        
        if newpath[newpath.startIndex] == "/" {
            newpath.removeFirst()
        }
        
        if newpath.contains(".") {
            newpath.removeLast(4)
        }
        
        let url = "https://image.tmdb.org/t/p/" + (size == nil ? "original" : "w" + String(size!))  + "/" + newpath + "." + type.filePathExtension
        
        return Future<UIImage, MovieAPIError> { promise in
            
            DispatchQueue.global().async {
                 
                if let url = Foundation.URL(string:url) {
                
                    do {
                        
                        let data = try Data(contentsOf:url)
                        
                        if let image = UIImage(data:data) {
                            
                            DispatchQueue.main.async {
                                promise(.success(image))
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                promise(.failure(MovieAPIError.ImageCouldInitialize))
                            }
                        }
                    }
                    catch {
                        DispatchQueue.main.async {
                            promise(.failure(MovieAPIError.MediaObjectLoad(error.localizedDescription)))
                        }
                    }
                }
                else {
                    assert(false)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


extension MovieAPIImpl {
    
    fileprivate static let APIKey = "a6eb30752c8935dcae9e5b56df0a9d9f"
}

///
/// Utility functions used by the implementation of MovieAPI
///
extension MovieAPIImpl {
    
    fileprivate static func URLRequest(url:URL, timeout:Int = 10) -> URLRequest {
        
        Foundation.URLRequest(url:url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(timeout))
    }
    
    fileprivate static func URL(apiurl:String, page:Int) -> URL {
        
        let string = apiurl + "?" + "api_key=" + Self.APIKey + "&language=en-US&page=\(page)"
        
        return Foundation.URL(string:string)!
    }
    
    fileprivate static func URL(apiurl:String) -> URL {
        
        let string = apiurl + "?" + "api_key=" + Self.APIKey + "&language=en-US"
        
        return Foundation.URL(string:string)!
    }
}

extension MediaObjectType {
    
    var filePathExtension: String {
        switch self {
            case .JPG: return "jpg"
            case .PNG: return "png"
            case .SVG: return "svg"
        }
    }
}

///
/// Extension that provides textual description of errors
///
extension MovieAPIError: LocalizedError {
    
    var errorDescription: String? {
        
        switch self {
        
            case let .InvalidParameter(string):
                return "Invalid parameter error: " + string
                
            case let .MediaObjectLoad(string):
                return "Error in load of Media Object - probably because URL cannot be read. Additional info: " + string
            
            case let .HTTPGetRequest(error):
                return error.localizedDescription
            
            case .ImageCouldInitialize:
                return "Data conversion error. Data could not be converted to an image."
        }
    }
}

