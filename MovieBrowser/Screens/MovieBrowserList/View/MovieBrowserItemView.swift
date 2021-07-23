//
//  MovieBrowserItemViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import SwiftUI

struct MovieBrowserItemView: View {
    
    @StateObject var viewModel: MovieBrowserItemViewModel
    
    /// Private
    
    private let height = CGFloat(200)
    private let textHeight = CGFloat(50)
    
    var body: some View {

        VStack(alignment:.center, spacing:0) {
            
            if let image = viewModel.posterImage {
                
                Image(uiImage:image)
                    .resizable()
                    .aspectRatio(contentMode:.fill)
                    .frame(maxWidth:.infinity).frame(height:height-textHeight)
                    .clipped()
            }
            else {
                
                Image(systemName:"photo")
                    .frame(maxWidth:.infinity, maxHeight:.infinity)
                    .foregroundColor(.white)
                    .background(StyleColor.imagePlaceHolderBackground)
                    .clipped()
            }

            Text(viewModel.title)
                .font(.system(size: 14, weight:.medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(height:textHeight)
                .padding(.horizontal)
        }
        .frame(height:height)
        .frame(maxWidth:.infinity)
        .background(Color(UIColor.systemGray4))
        .cornerRadius(10)
        .onAppear(perform: { viewModel.onAppear() })
        .onDisappear(perform: { viewModel.onDisappear() })
    }
}

struct MovieBrowserItemView_Previews: PreviewProvider {
    static let posterPath = "xipF6XqfSYV8DxLqfLN6aWlwuRp.jpg"
    static let model = MovieModel(id: 1, posterPath:posterPath, title:"title", overview:nil, releaseDate:nil, genres:nil, voteAverage: nil)
    static var previews: some View {
        HStack {
            MovieBrowserItemView(viewModel: MovieBrowserItemViewModel(model:model, api:MovieAPIImpl()))
            MovieBrowserItemView(viewModel: MovieBrowserItemViewModel(model:model, api:MovieAPIImpl()))
        }
        .padding()
    }
}

