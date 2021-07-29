//
//  Protocols.swift
//  Reusable
//
//  Created by Anders Lassen on 23/07/2021.
//

import Foundation
import SwiftUI
import CoreData


public protocol IdentifiableHashable: Identifiable, Hashable {
    
    
}

public extension IdentifiableHashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public protocol Model {
    
}


/// A protocol that provide access to underlying model object
public protocol ModelObjectAccessor {
    associatedtype ModelType: Model
    var modelObject: ModelType { get }
}

/// A protocol that provide access to underlying model object
public protocol ModelObjectOptionalAccessor {
    associatedtype ModelType: Model
    var modelObject: ModelType? { get }
}

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
