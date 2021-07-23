//
//  MovieBrowserDetailView.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import SwiftUI
import Reusable

struct MovieBrowserDetailView: View {
    
    @StateObject var viewModel: MovieBrowserDetailViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        
        GeometryReader { geometryReader in
            
            VStack(alignment:.leading, spacing:15) {
                
                if let image = viewModel.posterImage {
                    
                    Image(uiImage:image)
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                        .frame(maxWidth:.infinity).frame(height:0.4*geometryReader.size.height)
                        .clipped()
                }
                else {
                    
                    Image(systemName:"photo")
                        .frame(maxWidth:.infinity).frame(height:0.4*geometryReader.size.height)
                        .foregroundColor(.white)
                        .background(StyleColor.imagePlaceHolderBackground)
                }
                
                Group {
                    Text(viewModel.title)
                        .fontWeight(.heavy)
                    
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
                .padding(.horizontal,5)
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
    
    private func save() {
        viewModel.saved.toggle()
    }
    
    private func onAppear() {
        viewModel.onAppear()
    }
    
    private func onDisappear() {
        viewModel.onDisappear()
    }
}

extension MovieBrowserDetailView {
    
    private var navbarLeadingView: some View {
        Button(action:navigateBack) {
            Image(systemName:"arrow.left")
                .foregroundColor(.blue)
        }
    }
    
    private var navbarTrailingView: some View {
        Image(systemName:viewModel.saved ? "archivebox.fill" : "archivebox")
            .imageScale(.large)
            .foregroundColor(Color.blue)
            .frame(height:20)
            .onTapGesture(perform:save)
    }
}

struct MovieBrowserDetailView_Previews: PreviewProvider {
    static let title = "Movie Title"
    static let posterPath = "xipF6XqfSYV8DxLqfLN6aWlwuRp.jpg"
    static let store = PersistentStore(storeName: "MovieBrowser")
    static let genres = [1,2]
    static let releaseDate = "12-12-2021"
    static let model = MovieModel(id: 1, posterPath:posterPath, title:title, overview:Strings.loremIpsumShort, releaseDate:releaseDate, genres:genres, voteAverage: 5.5)
    static var previews: some View {
        MovieBrowserDetailView(viewModel: MovieBrowserDetailViewModel(model:model, api:MovieAPIImpl(), moc:Self.store.managedObjectContext!))
    }
}
