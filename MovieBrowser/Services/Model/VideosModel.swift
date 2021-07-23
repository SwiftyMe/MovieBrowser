//
//  VideosModel.swift
//  MovieBrowser
//
//  Created by Anders Lassen on 19/06/2021.
//

import Foundation

struct VideosModel: Codable {
    let id: Int
    let results: [VideoModel]?
}
