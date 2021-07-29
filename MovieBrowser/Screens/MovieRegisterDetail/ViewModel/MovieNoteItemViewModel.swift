//
//  NoteItemViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 21/07/2021.
//

import Foundation
import SwiftUI
import CoreData
import Reusable
import MovieBEService


///
/// View-model class for a user-registered movie
///
class MovieNoteItemViewModel: ObservableObject, Identifiable, Hashable, CoreDataModelObjectAccessor  {
   
    static func == (lhs: MovieNoteItemViewModel, rhs: MovieNoteItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Identifiable conformance
    var id: NSManagedObjectID {
        note.objectID
    }
    
    /// ModelObjectAccessor conformance
    var modelObject: DBNote {
        note
    }
    
    @Published var created: String
    @Published var modified: String
    @Published var text: String

    init(note: DBNote) {
        
        self.note = note
        
        text = note.text

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        created = formatter.string(from:note.created)
        modified = note.modified == nil ? "" : formatter.string(from:note.modified!)
    }

    private var note: DBNote
}
