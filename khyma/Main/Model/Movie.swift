//
//  Movie.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation
import UIKit

struct Movie {
    let name: String
    let youtubeUrl: String
    let posterImage: UIImage
    
    init(name: String, poster: UIImage) {
        self.name = name
        self.youtubeUrl = "https://www.youtube.com/watch?v=x_me3xsvDgk"
        self.posterImage = poster
    }
}
