//
//  Protocols.swift
//  Reusable
//
//  Created by Anders Lassen on 23/07/2021.
//

import Foundation
import SwiftUI
import CoreData

/// A protocol that provide access to underlying model object
public protocol JSONModelObjectAccessor {
    associatedtype ModelType: Decodable
    var modelObject: ModelType { get }
}

/// A protocol that provide access to underlying model object
public protocol CoreDataModelObjectAccessor {
    associatedtype ModelType: NSManagedObject
    var modelObject: ModelType { get }
}
