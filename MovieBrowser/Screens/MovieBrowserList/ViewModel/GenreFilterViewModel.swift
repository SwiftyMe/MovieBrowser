//
//  GenreFilterViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 22/07/2021.
//

import Foundation
import Reusable

///
/// View-model class for a browser movie item
///
class GenreFilterItemViewModel: ObservableObject, Identifiable, Hashable, JSONModelObjectAccessor {
    
    static func == (lhs: GenreFilterItemViewModel, rhs: GenreFilterItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// ModelObjectAccessor conformance
    var modelObject: GenreModel {
        model
    }

    /// Identifiable conformance
    var id: Int {
        model.id
    }
    
    var name: String {
        model.name ?? ""
    }
    
    @Published var included: Bool
    
    init(model: GenreModel) {

        self.model = model
        
        included = true
    }
    
    private let model: GenreModel
}
