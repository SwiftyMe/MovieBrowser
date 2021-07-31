//
//  MovieRegisterListView.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 12/07/2021.
//

import SwiftUI
import MovieBEService

struct MovieRegisterListView: View {
    
    @StateObject var viewModel: MovieRegisterListViewModel
    
    /// Private
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.movieService) private var movieService
    
    @State private var selectedMovie: MovieRegisterItemViewModel? = nil
    @State private var editMode = EditMode.inactive

    var body: some View {
        
        VStack(spacing:0) {
                       
            List {

                ForEach(viewModel.movies, content:navigationLink)
                    .onDelete(perform:deleteMovies)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.white)
            }
            .listStyle(PlainListStyle())
            .padding(.vertical,7)
            .background(Color.white)
            .environment(\.editMode, $editMode)
        }
        .configureNavigationBar(leading:navbarLeadingView, center:navbarCenterView, trailing: navbarTrailingView)
        .onAppear(perform:onAppear)
        .onDisappear(perform:onDisappear)
    }
    
    private func onAppear() {
        viewModel.onAppear()
        UITableView.appearance().backgroundColor = UIColor.white
    }
    
    private func onDisappear() {
        viewModel.onDisappear()
    }
    
    private func navigateBack() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func navigationLink(movie: MovieRegisterItemViewModel) -> some View {

        ZStack {

            MovieRegisterItemView(viewModel: movie)
                .background(Color.white)
                .onTapGesture {
                    if movie.modelObject != nil {
                        selectedMovie = movie
                    }
                }

            NavigationLink(
                destination: MovieRegisterDetailView(viewModel: MovieRegisterDetailViewModel(movie: movie.registeredMovie, model: movie.modelObject!, service: movieService)), tag:movie, selection:$selectedMovie, label: { EmptyView() })
                .disabled(true)
                .hidden()
        }
    }
    
    private func deleteMovies(at indexes: IndexSet) {
        viewModel.deleteMovies(at:indexes)
    }
}

extension MovieRegisterListView {
    
    private var navbarLeadingView: some View {
        Button(action:navigateBack) {
            Image(systemName:"arrow.left")
                .foregroundColor(.blue)
        }
    }
    
    private var navbarCenterView: some View {
        Text("My Movie Register")
    }
    
    private var navbarTrailingView: some View {
        Button(action: { editMode = editMode == .active ? .inactive : .active }) {
            Image(systemName:"xmark.bin")
        }
    }
}

struct MovieRegisterListView_Previews: PreviewProvider {
    static let store = PersistentStore(storeName: "MovieBrowser")
    static let service = MovieServiceImplementation()
    static var previews: some View {
        MovieRegisterListView(viewModel: MovieRegisterListViewModel(moc: store.managedObjectContext!, movieService:service))
    }
}
