//
//  NoteItemView.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 21/07/2021.
//

import SwiftUI
import Reusable
import MovieBEService

struct MovieNoteItemView: View {
    
    let note: String
    let date: String
    
    var body: some View {
        
        // - FIXME: Attributed string is soon coming in iOS 15
        
        ZStack(alignment:.topLeading) {
            
            Text(date)
                .font(.system(size: 15, weight: .ultraLight))
                .offset(x:0, y:1)
            
            Text("                       " + note)
                .lineLimit(2)
                .font(.system(size: 16, weight: .regular))
                .lineSpacing(StyleLayout.textualLineSpacing)
                .foregroundColor(StyleColor.noteText)
        }
        .frame(height:50)
        .padding(.vertical,7)
    }
}


struct MovieNoteItemView_Previews: PreviewProvider {
    static var previews: some View {
        MovieNoteItemView(note: Strings.loremIpsumShort, date: "10/10/2021")
            .padding()
    }
}
