//
//  GenreFilterViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 22/07/2021.
//

import Foundation
import Reusable
import MovieBEService

///
/// View-model class for a browser movie item
///
class GenreFilterItemViewModel: ObservableObject, Identifiable, Hashable {
    
    static func == (lhs: GenreFilterItemViewModel, rhs: GenreFilterItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }


    /// Identifiable conformance
    var id: String {
        model
    }
    
    var name: String {
        model
    }
    
    @Published var included: Bool
    
    init(model: String, isIncluded: Bool) {

        self.model = model
        self.included = isIncluded
    }
    
    private let model: String
}
