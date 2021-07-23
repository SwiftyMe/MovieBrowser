//
//  DatabaseController.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 15/07/2021.
//

import Foundation
import CoreData

class PersistentStore {
    
    enum Error: Swift.Error {
        case objectModelNotFound
        case couldNotLoad(NSError)
    }
    
    var container: NSPersistentContainer?
    var error: Error?
    
    var managedObjectContext: NSManagedObjectContext? {
        container?.viewContext
    }

    init(storeName: String) {
        
        container = NSPersistentContainer(name: storeName)
        
        var loadCalled = false
 
        /// if storeName is not found to be a model file, container will be set to 0x0000000000 (?),
        /// which again will lead to the "loadPersistentStores" function not being called.
        
        /// According to documentation, this called wil by default run synchronously on the main thread
        container?.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            assert(Thread.isMainThread)

            if let error = error as NSError? {
                
                self.error = .couldNotLoad(error)
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The store could not be migrated to the current model version.
                 */
            }
        
            loadCalled = true
        })

        if !loadCalled {
            error = .objectModelNotFound
        }
        
        if error != nil {
            container = nil
        }
    }
}
