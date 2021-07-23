//
//  File.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 14/07/2021.
//

import Foundation
import CoreData


class DBMovie: NSManagedObject, DBCreatable  {

    // Attributes
    
    @NSManaged var tmdbId: Int32
    @NSManaged var created: Date
    @NSManaged var rating: Int16 // 0 ... 100
    
    // Relations

    @NSManaged var notes: NSSet
}


extension DBMovie {
    
    override func awakeFromInsert() {
        super.awakeFromInsert()

        created = Date()
        assert(notes.count == 0)
    }
}

extension DBMovie {
    
    public class func fetchMovieWithId(id:Int32, moc: NSManagedObjectContext) throws -> DBMovie? {
        
        let request = NSFetchRequest<DBMovie>(entityName:DBMovie.entityName)
        
        request.predicate = NSPredicate(format: "tmdbId == %d", id)
        
        do {
            
            let objects = try moc.fetch(request)
            
            assert(objects.count < 2)

            return objects.first
        }
        catch {
            let nserror = error as NSError
            print(nserror)
            assert(false)
            throw error
        }
    }
    
}
