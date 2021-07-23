//
//  MovieNoteViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 21/07/2021.
//

import Foundation
import SwiftUI
import CoreData
import Reusable

///
/// View-model class for a user-registered movie
///
class MovieNoteViewModel: ObservableObject  {
    
    @Published var text: String {
        didSet {
            updateTextModelProperty(text)
        }
    }
    
    var isNewNote: Bool {
        note.modified == nil
    }
   
    init(note: DBNote) {
        
        self.note = note
        
        text = note.text
    }

    private var note: DBNote
}

extension MovieNoteViewModel {
    
    private func updateTextModelProperty(_ text: String) {
        note.text = text
        note.modified = Date()
    }
}
