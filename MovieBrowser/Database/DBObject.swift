//
//  File.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 14/07/2021.
//

import Foundation
import CoreData


public protocol DBCreatable: NSManagedObject {
    
    static func create(_ moc: NSManagedObjectContext) -> Self
    
    var entityName: String { get }
    
    static var entityName: String { get }
}

public extension DBCreatable {
    
    var entityName: String {
        return Self.entityName
    }
    
    static var entityName: String {
        var name = NSStringFromClass(Self.self)
        name.removeSubrange(name.startIndex ..< name.firstIndex(of:".")!)
        name.removeFirst(3)
        return name
    }
    
    static func create(_ moc: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName:entityName, into:moc) as! Self
    }
}


public class DBObjects {
    
    public class func fetchAll<Object:DBCreatable>(moc:NSManagedObjectContext) throws -> [Object] {
        
        let request = NSFetchRequest<Object>(entityName:Object.entityName)
        
        do {
            let objects = try moc.fetch(request)
            
            return objects
        }
        catch {
            let nserror = error as NSError
            print(nserror)
            assert(false)
            throw error
        }
    }
}


protocol DBContext: AnyObject {
    
    var moc: NSManagedObjectContext { get }
    
    func storeSave()
    func storeError(_:Error)
}

extension DBContext {
    
    func storeSave() {
        
        do {
            
            try moc.save()
        }
        catch {
            
            storeError(error)
        }
    }
}
