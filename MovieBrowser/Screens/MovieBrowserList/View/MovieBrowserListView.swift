//
//  MovieBrowseView.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import SwiftUI
import Reusable
import MovieBEService

struct MovieBrowserListView: View {
    
    @StateObject var viewModel: MovieBrowserListViewModel
    
    /// Private
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.movieService) private var movieService
    
    @State private var searchVisible = false
    @State private var clicked = false
    @State private var showGenresSheet = false
    
    private var columns: [GridItem] { Array(repeating: .init(.flexible()), count: 2) }
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment:.leading, spacing:15) {
                
                ScrollView {
                    
                    ScrollViewReader { scrollReader in
                        
                        LazyVGrid(columns:columns, alignment: .leading, spacing:15) {
                            ForEach(viewModel.movies, content:navigationLink)
                        }
                        .onReceive(viewModel.scrollToTop, perform: { value in
                            scrollReader.scrollTo(value)
                        })
                    }
                }

                StyleColor.divider.frame(height:1)
                    .padding(.horizontal,5)
                
                if searchVisible {
                    
                    SearchTextField(placeholder: "Enter text", searchText: $viewModel.searchText)
                }
                else {
                    
                    Picker("", selection:$viewModel.movieList) {
                        ForEach(Array(MovieList.allCases)) { list in
                            Text(list.description)
                                .tag(list)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
            .sheet(isPresented:$showGenresSheet, onDismiss: genresSheetDismissed,  content: genresSheet)
            .configureNavigationBar(leading:navbarLeadingView, trailing1:navbarTrailingView1, trailing2:navbarTrailingView2, trailing3:navbarTrailingView3)
            .onAppear(perform:onAppear)
            .onDisappear(perform:onDisappear)
        }
    }

    private func onAppear() {
        viewModel.onAppear()
    }
    
    private func onDisappear() {
    }
}

extension MovieBrowserListView {

    private func navigationLink(movie: MovieBrowserItemViewModel) -> some View {
        
       NavigationLink(
            destination: MovieBrowserDetailView(viewModel:MovieBrowserDetailViewModel(model:movie.modelObject, movieService:movieService, moc:moc)),
            label: { MovieBrowserItemView(viewModel: movie).id(movie.id) })
    }
    
    private func genresSheet() -> some View {
        
        VStack(alignment:.leading, spacing:20) {
            
            HStack {
                
                Button(action: { showGenresSheet.toggle() }) {
                    Image(systemName:"arrow.left")
                }
                
                Spacer()
                
                Text("Genre Filter")
                    .fontWeight(.bold)
                    .padding(.trailing,20)
                
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal)
            
            Text("The genre filter works by only showing the movies having genres that are selected by the filter.")
                .font(.system(size: 14, weight: .light))
                .padding(.horizontal)
            
            ScrollView {
                
                ForEach(viewModel.genreFilter) { filter in
                    GenreFilterView(genre:filter)
                }
                .padding(.horizontal)
            }
            
            HStack {
            
                Button(action:genresFilterSelectAll) {
                    Text("Select All")
                }
                .frame(width:100)
                
                Spacer()
                
                Button(action:genresFilterDeselectAll) {
                    Text("Deselect All")
                }
                .frame(width:100)
            }
            .padding(.vertical,5)
        }
        .padding()
    }
    
    private func genresSheetDismissed() {

        viewModel.updateGenreFilter()
    }
    
    private func genresFilterSelectAll() {

        viewModel.genreFilterSelectAll()
    }
    
    private func genresFilterDeselectAll() {
        
        viewModel.genreFilterDeselectAll()
    }
}

extension MovieBrowserListView {
    
    private var navbarLeadingView: some View {
        Text("Movie browser")
            .font(.system(size:24, weight: .medium))
    }
    
    private var navbarTrailingView1: some View {
        Image(systemName: searchVisible ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
            .imageScale(.large)
            .foregroundColor(.blue)
            .onTapGesture(perform:search)
    }
    
    private var navbarTrailingView2: some View {
        NavigationLink(
            destination: MovieRegisterListView(viewModel: MovieRegisterListViewModel(moc:moc, movieService: movieService)), label: {
                Image(systemName:"archivebox")
            })
    }
    
    private var navbarTrailingView3: some View {
        Image(systemName:"line.horizontal.3.decrease.circle")
            .imageScale(.large)
            .foregroundColor(.blue)
            .onTapGesture(perform:showGenres)
    }
    
    private func search() {
        
        searchVisible.toggle()
        
        if !searchVisible {
            
            viewModel.searchText = ""
        }
    }
    
    private func showGenres() {
        showGenresSheet = true
    }
}

///
///
///
extension MovieList: CustomStringConvertible, Identifiable {
    
    public var id: String {
        description
    }
    
    public var description: String {
        switch self {
            case .popular: return "Popular"
            case .topRated: return "Top Rated"
            case .upComing: return "Upcoming"
        }
    }
}



struct MovieBrowseView_Previews: PreviewProvider {
    static let service = MovieServiceImplementation()
    static var previews: some View {
        MovieBrowserListView(viewModel:MovieBrowserListViewModel(service:service))
    }
}
