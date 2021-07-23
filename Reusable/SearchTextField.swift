//
//  SearchField.swift
//  Reusable
//
//  Created by Anders Lassen on 15/07/2021.
//

import SwiftUI

public struct SearchTextField: View {
    
    public let placeholder: String
    @Binding public var searchText: String
    
    public init(placeholder: String, searchText: Binding<String>) {
        self.placeholder = placeholder
        self._searchText = searchText
    }
    
    public var body: some View {
        
        HStack  {
            
            Image(systemName:"magnifyingglass")
                .imageScale(.large)
                .foregroundColor(.gray)
                .padding(.leading, 12)
            
            TextField(placeholder, text:$searchText) { isEditing in
            } onCommit: {
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.vertical, 10)
        }
        .background(Color.init(.sRGB ,white:0.94))
        .cornerRadius(7)
    }
}

struct SearchField_Previews: PreviewProvider {
    
    static let searchText = Binding<String>.constant("123")
    
    static var previews: some View {
        SearchTextField(placeholder: "", searchText: searchText)
    }
}
