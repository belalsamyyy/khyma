//
//  Episodes.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit

class Episode: Video {
    var name: String?
    var posterImageUrl: String? // just to conform watchable
    var youtubeUrl: String?
    
    init(name: String, youtubeUrl: String) {
        self.name = name
        self.youtubeUrl = youtubeUrl
    }
}
