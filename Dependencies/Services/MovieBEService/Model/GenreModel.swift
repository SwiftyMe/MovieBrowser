//
//  GenreModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 25/07/2021.
//

import Foundation

public enum MovieGenre {
    
    case action,
         adventure,
         animation,
         comedy,
         crime,
         documentary,
         drama,
         family,
         fantasy,
         history,
         horror,
         music,
         mystery,
         romance,
         scienceFiction,
         thriller,
         tvMovie,
         war,
         western
    
    case other(String)
}

extension MovieGenre: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
            case .action: return "Action"
            case .adventure: return "Adventure"
            case .animation: return "Animation"
            case .comedy: return "Comedy"
            case .crime: return "Crime"
            case .documentary: return "Documentary"
            case .drama: return "Drama"
            case .family: return "Family"
            case .fantasy: return "Fantasy"
            case .history: return "History"
            case .horror: return "Horror"
            case .music: return "Music"
            case .mystery: return "Mystery"
            case .romance: return "Romance"
            case .scienceFiction: return "Science Fiction"
            case .thriller: return "Thriller"
            case .tvMovie: return "TV Movie"
            case .war: return "War"
            case .western: return "Western"
            case .other(let genre): return "Other - \(genre)"
        }
    }
}

extension MovieGenre: CaseIterable {
    
    public static var allCases: [MovieGenre] = [
        action,
        adventure,
        animation,
        comedy,
        crime,
        documentary,
        drama,
        family,
        fantasy,
        history,
        horror,
        music,
        mystery,
        romance,
        scienceFiction,
        thriller,
        tvMovie,
        war,
        western
    ]
}
