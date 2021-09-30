//
//  Movie.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation
import UIKit
import SimpleAPI

class Video: NSObject, Watchable, NSCoding, NSSecureCoding, Model {
    // API
    static var endpoint: String!
    static var params: Params?
    static var headers: Headers?
    
    // properties
    var name: String?
    var posterImageUrl: String?
    var youtubeUrl: String?
    
    // just to confirm watchable
    var seasons: [Season]?

    // NSSecureCoding
    static var supportsSecureCoding: Bool = true
    
    init(name: String, posterUrl: String, youtubeUrl: String) {
        self.name = name
        self.youtubeUrl = youtubeUrl
        self.posterImageUrl = posterUrl
    }
    
    func encode(with coder: NSCoder) {
        // encode Movie object into data
        coder.encode(name ?? "", forKey: "name")
        coder.encode(youtubeUrl ?? "", forKey: "youtubeUrl")
        coder.encode(posterImageUrl ?? "", forKey: "posterImageUrl")
        coder.encode(seasons ?? [], forKey: "seasons")
    }
    
    required init?(coder: NSCoder) {
        // decode data into Movie object again
        self.name = coder.decodeObject(forKey: "name") as? String
        self.youtubeUrl = coder.decodeObject(forKey: "youtubeUrl") as? String
        self.posterImageUrl = coder.decodeObject(forKey: "posterImageUrl") as? String
        self.seasons = coder.decodeObject(forKey: "seasons") as? [Season]
    }
    
}



