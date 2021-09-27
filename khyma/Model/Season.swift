//
//  Season.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit

class Season: Watchable {
    var continueWatching: Float?
    
    var name: String?
    var posterImageUrl: String?
    var youtubeUrl: String?
    var episodes: [Episode]?
    
    init(name: String, posterImageUrl: String, episodes: [Episode]) {
        self.name = name
        self.posterImageUrl = posterImageUrl
        self.episodes = episodes
    }
}
