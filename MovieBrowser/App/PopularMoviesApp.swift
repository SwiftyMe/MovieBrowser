//
//  MovieBrowserApp.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import SwiftUI
import Combine
import CoreData

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
                
                MovieBrowserListView(viewModel: MovieBrowserListViewModel(api:MovieAPIKey.defaultValue))
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

private struct MovieAPIKey: EnvironmentKey {
    static let defaultValue: MovieAPI = MovieAPIImpl()
}

extension EnvironmentValues {
  var movieAPI: MovieAPI {
    get { self[MovieAPIKey.self] }
    set { self[MovieAPIKey.self] = newValue }
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
