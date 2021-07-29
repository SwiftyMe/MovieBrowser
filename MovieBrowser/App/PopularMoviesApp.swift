//
//  MovieBrowserApp.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import SwiftUI
import Combine
import CoreData
import MovieBEService

@main
struct MovieBrowserApp: App {
    
    @ObservedObject var store = StoreLoader()
    
    init() {
        
        var defaults = [String: AnyObject]()
        
        defaults[UserDefaults.genres] = [Int]() as AnyObject

        UserDefaults.standard.register(defaults: defaults)
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            if store.success {
                
                MovieBrowserListView(viewModel: MovieBrowserListViewModel(service:MovieServiceKey.defaultValue))
                    .environment(\.managedObjectContext, store.managedObjectContext!)
            }
            else if let error = store.error {
                
                Text(error.localizedDescription)
            }
            else {
                
                Text("Loading Database ...")
            }
        }
    }
}

private struct MovieServiceKey: EnvironmentKey {
    static let defaultValue: MovieService = MovieServiceImplementation()
}

extension EnvironmentValues {
  var movieService: MovieService {
    get { self[MovieServiceKey.self] }
    set { self[MovieServiceKey.self] = newValue }
  }
}


class StoreLoader: ObservableObject {
    
    @Published var error: Error?
    @Published var success = false
    
    var managedObjectContext: NSManagedObjectContext? {
        store?.managedObjectContext
    }
    
    private let store: PersistentStore?
    
    init() {
        
        store = PersistentStore(storeName: "MovieBrowser")
        
        if store == nil {
            
            error = store!.error
        }
        else {
            
            success = true
        }
    }
}

extension UserDefaults {
    
    static var genres: String { "genres" }
}
