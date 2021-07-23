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

///
/// View-model class for a browser movie item
///
class MovieBrowserItemViewModel: ObservableObject, Identifiable, Hashable, JSONModelObjectAccessor, ViewLifeCycleEvents {
    
    static func == (lhs: MovieBrowserItemViewModel, rhs: MovieBrowserItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// ModelObjectAccessor conformance
    var modelObject: MovieModel {
        model
    }

    /// Identifiable conformance
    var id: Int {
        model.id
    }
    
    @Published var title: String
    @Published var posterImage: UIImage?
    
    @Published var visible = false {
        didSet {
            visibleChanged.send(self)
        }
    }
    
    let visibleChanged = PassthroughSubject<MovieBrowserItemViewModel,Never>()

    func onAppear() {

        guard !visible else { return }
        
        visible = true
        updatePosterImage()
    }
    
    func onDisappear() {
    }
    
    init(model: MovieModel, api: MovieAPI) {

        self.model = model
        self.api = api
        
        title = model.title ?? ""
    }
    
    private let model: MovieModel
    private let api: MovieAPI
    private var cancellable: AnyCancellable?
}


extension MovieBrowserItemViewModel {
    
    private func updatePosterImage() {

        guard let posterPath = model.posterPath else {
           return
        }
        
        cancellable = api.mediaObject(path:posterPath, size:200, type:.JPG).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] value in
                self?.posterImage = value
            })
    }
}
