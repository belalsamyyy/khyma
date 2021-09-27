//
//  Episodes.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit

class Episode: Watchable {
    var name: String?
    var posterImageUrl: String?
    var youtubeUrl: String?
    var continueWatching: Float?
    
    init(name: String, youtubeUrl: String) {
        self.name = name
        self.youtubeUrl = youtubeUrl
    }
}
