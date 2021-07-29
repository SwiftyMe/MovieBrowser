//
//  ViewLifeCycleEvents.swift
//  Reusable
//
//  Created by Anders Lassen on 19/07/2021.
//

import Foundation


public protocol ViewLifeCycleEvents {
    
    func onAppear()
    func onDisappear()
}

public protocol ViewLifeCycleEventsInfo {
    
    func onAppear()
    func onDisappear()
}

public extension ViewLifeCycleEventsInfo {
    
    func onAppear() {
        print("\(type(of: self)) - onAppear")
    }
    
    func onDisappear() {
        print("\(type(of: self)) - onDisappear")
    }
}
