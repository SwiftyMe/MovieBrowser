//
//  File2.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 14/07/2021.
//

import Foundation
import CoreData


class DBNote: NSManagedObject, DBCreatable  {

    // Attributes
    
    @NSManaged var tmdbId: Int32
    @NSManaged var created: Date
    @NSManaged var modified: Date?
    @NSManaged var text: String
    
    // Inverse Relations

    @NSManaged var movie: DBMovie?
}

extension DBNote {
    
    override func awakeFromInsert() {
        super.awakeFromInsert()

        created = Date()
    }
}
