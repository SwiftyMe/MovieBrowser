//
//  GenreFilterView.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 22/07/2021.
//

import SwiftUI

struct GenreFilterView: View {
    
    @ObservedObject var genre: GenreFilterItemViewModel
    
    var body: some View {

        Toggle(isOn: $genre.included) {
            Text(genre.name)
        }
    }
}
