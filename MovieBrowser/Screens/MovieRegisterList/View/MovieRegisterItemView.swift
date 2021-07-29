//
//  SwiftUIView.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 16/07/2021.
//

import SwiftUI
import MovieBEService

struct MovieRegisterItemView: View {
    
    @ObservedObject var viewModel: MovieRegisterItemViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            HStack(alignment:.center, spacing:0) {
                
                if let image = viewModel.posterImage {
                    
                    Image(uiImage:image)
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                        .frame(width:imageWidthScale*geometry.size.width,height:geometry.size.height)
                        .clipped()
                }
                else {
                    
                    Image(systemName:"photo")
                        .frame(width:imageWidthScale*geometry.size.width,height:geometry.size.height)
                        .foregroundColor(.white)
                        .background(StyleColor.imagePlaceHolderBackground)
                        .clipped()
                }
                
                VStack(alignment:.leading, spacing:10) {
                    
                    Text(viewModel.title)
                        .font(.system(size: 18, weight:.bold))
                        .foregroundColor(Color.black)
                        .lineLimit(1)
                    
                    HStack {
                        Text(viewModel.rating)
                            .font(.system(size: 12))
                            .foregroundColor(Color.init(white:0.0))
                            .lineLimit(1)
                        Spacer()
                    }
                    
                    Text(viewModel.overview)
                        .font(.system(size: 10))
                        .foregroundColor(Color.init(white:0.3))
                        .lineLimit(2)
                }
                .frame(maxWidth:.infinity)
                .padding(10)
            }
            .roundRectangleStyle(background:Color(UIColor.systemGray5),border:Color(UIColor.systemGray4))
        }
        .frame(height:height)
        .padding(.horizontal)
        .padding(.vertical,0.5*spacing)
        .onAppear(perform:onAppear)
        .onDisappear(perform:onDisappear)
    }
    
    let spacing = CGFloat(15)
    let imageWidthScale = CGFloat(1.0/3.5)
    let height = CGFloat(120)
    
    private func onAppear() {
        viewModel.onAppear()
    }
    
    private func onDisappear() {
        viewModel.onDisappear()
    }
}

struct MovieRegisterItemView_Previews: PreviewProvider {
    static let store = PersistentStore(storeName: "MovieBrowser")
    static let service = MovieServiceImplementation()
    static var previews: some View {
        MovieRegisterItemView(viewModel: MovieRegisterItemViewModel(movie:DBMovie.create(store.managedObjectContext!), service:service))
    }
}
