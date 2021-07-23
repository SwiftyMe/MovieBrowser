//
//  RegMovieNoteView.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 21/07/2021.
//

import SwiftUI

struct MovieNoteView: View {
    
    @StateObject var viewModel: MovieNoteViewModel
    
    /// Private
    
    @Environment(\.presentationMode) private var presentationMode
    
    private let placeholderText = "Enter Note Text..."
    @State private var showPlaceholderText = true
    
    var body: some View {
        
        VStack {

            TextEditor(text:$viewModel.text)
                .lineSpacing(StyleLayout.textualLineSpacing)
                .foregroundColor(StyleColor.noteText)
                .padding(5)
                .padding(.horizontal,2)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(white:0.94), lineWidth: 1))
                .background(
                    VStack {
                        HStack {
                            Text(viewModel.text.isEmpty && showPlaceholderText ? placeholderText : "")
                                .foregroundColor(Color.primary.opacity(0.25))
                                .padding(10)
                                .padding(.vertical,2)
                            Spacer()
                        }
                        Spacer()
                    }
                )
                .padding()
        }
        .onTapGesture {
            showPlaceholderText = false
        }
        .onAppear(perform: {
            UITextView.appearance().backgroundColor = .clear
        })
        .configureNavigationBar(leading:navbarLeadingView, center:navbarCenterView, trailing:EmptyView())
    }
}

extension MovieNoteView {
    
    private var navbarLeadingView: some View {
        Button(action:navigateBack) {
            Image(systemName:"arrow.left")
        }
    }
    
    private var navbarCenterView: some View {
        Text(viewModel.isNewNote ? "New Note" : "Edit Note")
    }
    
    private func navigateBack() {
        presentationMode.wrappedValue.dismiss()
    }
}


struct MovieNoteView_Previews: PreviewProvider {
    static let store = PersistentStore(storeName: "MovieBrowser")
    static var previews: some View {
        MovieNoteView(viewModel: MovieNoteViewModel(note: DBNote.create(store.managedObjectContext!)))
    }
}
