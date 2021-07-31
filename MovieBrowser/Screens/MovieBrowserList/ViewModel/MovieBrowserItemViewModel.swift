//
//  MovieViewModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import Foundation
import SwiftUI
import Combine
import Reusable
import MovieBEService

///
/// View-model class for a browser movie item
///
class MovieBrowserItemViewModel: ObservableObject, IdentifiableHashable, ModelObjectAccessor, ViewLifeCycleEvents {
    
    var id: Int { model.id }  /// Identifiable conformance
    
    var modelObject: MovieModel { model }  /// ModelObjectAccessor conformance
    
    @Published var title: String
    @Published var posterImage: UIImage?
    
    var visible = false {
        didSet {
            visibleChanged.send(self)
        }
    }
    
    let visibleChanged = PassthroughSubject<MovieBrowserItemViewModel,Never>()

    func onAppear() {

        assert(!visible)
        
        guard !visible else { return }
        
        print("MovieBrowserItemViewModel onAppear \(id)")
        
        movieService.updateModel(model: model)
        
        visible = true
    }
    
    func onDisappear() {
        
        visible = false
        
        print("MovieBrowserItemViewModel onDisappear \(id)")
    }
    
    init(model: MovieModel, service: MovieService) {

        print("MovieBrowserItemViewModel init \(model.id)")
        
        self.model = model
        self.movieService = service

        self.title = model.title
    }
    
    private var model: MovieModel
    private var movieService: MovieService
}


extension MovieBrowserItemViewModel {
    
    private func updatePropertyPosterImage() {
        posterImage = model.posterImage
    }
    
    private func updatePropertyTitle() {
        title = model.title
    }
}


extension MovieBrowserItemViewModel {
    
    func updateModel(model: MovieModel) {
        self.model = model
        updatePropertyPosterImage()
        updatePropertyTitle()
    }
}



