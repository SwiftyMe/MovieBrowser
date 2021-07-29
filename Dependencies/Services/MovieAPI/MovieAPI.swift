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
    
    typealias Error = MovieAPIError
    
    associatedtype MovieModel: Codable
    associatedtype MovieDetailModel: Codable
    associatedtype MoviesModel: Codable
    associatedtype GenresModel: Codable
    associatedtype GenreModel: Codable

    func movieDetail(id:Int) -> AnyPublisher<MovieDetailModel, Error>
    
    func MovieBrowser() -> AnyPublisher<[MovieModel], Error>
    
    func MovieBrowser(page: Int) -> AnyPublisher<MoviesModel, Error>
    func topRatedMovies(page: Int) -> AnyPublisher<MoviesModel, Error>
    func upComingMovies(page: Int) -> AnyPublisher<MoviesModel, Error>

    func movieGenres() -> AnyPublisher<[GenreModel], Error>
    
    func mediaObject(path:String, size: Int?, type: MediaObjectType) -> AnyPublisher<UIImage, Error>
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

