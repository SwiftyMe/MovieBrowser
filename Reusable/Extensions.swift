//
//  File.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 09/07/2021.
//

import Foundation
import SwiftUI


public extension RandomAccessCollection where Self.Element: Identifiable {
    
    ///
    /// Function used in presenting a paginated list with continuous scrolling
    ///
    /// Returns true if 'item' is after threshold position specified by offset, otherwise false
    ///
    /// Adapted from medium article:
    /// https://medium.com/better-programming/meet-greet-list-pagination-in-swiftui-8330ee15fd61
    ///
    func isThresholdItem<T: Identifiable>(delta:Int, item:T) -> Bool {
        
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = firstIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        let delta = delta < count ? delta : count - 1
        
        return delta == (distance - 1)
    }
}


public extension View {
    
    func roundRectangleStyle(background:Color,border:Color,cornerRadius:CGFloat=5) -> some View {
    
    self
        .background(background)
        .cornerRadius(cornerRadius)
        .overlay(RoundedRectangle(cornerRadius:cornerRadius).stroke(border,lineWidth:1))
    }
}


public func debug(_ string:String) -> some View {
    
    print(string)
    
    return EmptyView()
}

