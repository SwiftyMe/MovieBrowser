//
//  MovieRegisterDetailView.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 17/07/2021.
//

import SwiftUI
import Reusable
import MovieBEService

struct MovieRegisterDetailView: View {
    
    @StateObject var viewModel: MovieRegisterDetailViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    enum Tabs: Int, CaseIterable { case info, rating, notes }
    
    @State private var tab: Tabs = .info
    
    @State private var noteSelection: MovieNoteItemViewModel?
    
    private let imageHeightScale = CGFloat(0.5)
    
    var body: some View {
        
        GeometryReader { geometryReader in
            
            VStack(alignment:.leading, spacing:15) {
                
                if let image = viewModel.posterImage {
                    
                    Image(uiImage:image)
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                        .frame(maxWidth:.infinity).frame(height:imageHeightScale*geometryReader.size.height)
                        .clipped()
                }
                else {
                    
                    Image(systemName:"photo")
                        .frame(maxWidth:.infinity).frame(height:imageHeightScale*geometryReader.size.height)
                        .foregroundColor(.white)
                        .background(StyleColor.imagePlaceHolderBackground)
                }
                
                Text(viewModel.title)
                    .fontWeight(.heavy)
                
                Group {
                    switch tab {
                        case Tabs.info: infoView()
                        case Tabs.rating: ratingView()
                        case Tabs.notes: notesView()
                    }
                }
                .padding(.horizontal, 5)
                .padding(.top, 10)
            }
            .padding()
        }
        .onAppear(perform:onAppear)
        .onDisappear(perform:onDisappear)
        .configureNavigationBar(leading:navbarLeadingView, trailing:navbarTrailingView)
    }
    
    private func navigateBack() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func onAppear() {
        viewModel.onAppear()
    }
    
    private func onDisappear() {
        viewModel.onDisappear()
    }
}

extension MovieRegisterDetailView {
    
    private func infoView() -> some View {
        
        VStack(alignment: .leading, spacing:15) {
            
            Text(viewModel.genres)
                .fontWeight(.medium)
            
            Text(viewModel.releaseDate)
                .fontWeight(.medium)
            
            if let vote = viewModel.averageVote {
                Text(String("Rating: \(vote)"))
                    .fontWeight(.medium)
            }

            ScrollView {
                Text(viewModel.overview)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    private func ratingView() -> some View {
        
        VStack(alignment:.leading, spacing:5) {
            HStack {
                Text("Rating:").fontWeight(.medium)
                Text(String(format: "%.1f", 0.1 * viewModel.rating))
            }
            Slider(value: $viewModel.rating, in: 0...99)
        }
    }
    
    private func notesView() -> some View {
        
        VStack(alignment: .leading, spacing: 15) {
            
            List {
                
                ForEach(viewModel.notes, content:navigationLink)
                    .onDelete(perform:deleteMovies)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.white)
            }
            .listStyle(PlainListStyle())
            .padding(.top,-10)
            
            Button(action: {
                noteSelection = viewModel.addNote()
            }) {
                if viewModel.notes.isEmpty {
                    Label("Add Note", systemImage: "plus")
                        .imageScale(.large)
                        .labelStyle(TitleAndIconLabelStyle())
                }
                else {
                    Label("Add Note", systemImage: "plus")
                        .imageScale(.large)
                        .labelStyle(IconOnlyLabelStyle())
                }
            }
        }
    }
    
    private func navigationLink(note: MovieNoteItemViewModel) -> some View {

        ZStack(alignment:.leading) {
            
            MovieNoteItemView(note:note.text, date:note.created)
                .onTapGesture {
                    noteSelection = note
                }

            NavigationLink(destination: MovieNoteView(viewModel: MovieNoteViewModel(note:note.modelObject)),
                           tag: note, selection: $noteSelection, label: { EmptyView() })
                .hidden()
                .disabled(true)
        }
    }
    
    private func deleteMovies(at indexes: IndexSet) {
        viewModel.deleteMovies(at:indexes)
    }
}

extension MovieRegisterDetailView {
    
    private var navbarLeadingView: some View {
        Button(action:navigateBack) {
            Image(systemName:"arrow.left")
        }
    }
    
    private var navbarTrailingView: some View {
        Picker("", selection:$tab) {
            ForEach(Array(Tabs.allCases)) { list in
                Text(" "+list.description+" ")
                    .tag(list)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}


///
/// Protocol conformance for the Tabs enum
///
extension MovieRegisterDetailView.Tabs: CustomStringConvertible, Identifiable {
    
    var id: Int {
        rawValue
    }
    
    public var description: String {
        switch self {
            case .info: return "Info"
            case .rating: return "My Rating"
            case .notes: return "My Notes"
        }
    }
}


struct MovieRegisterDetailView_Previews: PreviewProvider {
    static let service = MovieServiceImplementation()
    static let store = PersistentStore(storeName: "MovieBrowser")
    static let genres = [MovieGenre.drama,MovieGenre.thriller]
    static let model = MovieDetailModel(id: 1, posterImage:nil, title:"The Tomorrow war", overview:Strings.loremIpsumLong, genres:genres, releaseDate:"2021-07-11", voteAverage:5.6)
    
    static var previews: some View {
        MovieRegisterDetailView(viewModel:
                                    MovieRegisterDetailViewModel(movie: DBMovie.create(store.managedObjectContext!), model: model, service:service))
    }
}
