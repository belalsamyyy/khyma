//
//  Episode.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import SimpleAPI

class Series: NSObject, Watchable, NSCoding, NSSecureCoding {    
    // Properties
    var name: String?
    var posterImageUrl: String?
    var youtubeUrl: String?
    var seasons: [Season]?
    
    // NSSecureCoding
    static var supportsSecureCoding: Bool = true
    
    init(name: String, posterUrl: String, seasons: [Season]) {
        self.name = name
        self.youtubeUrl = ""
        self.posterImageUrl = posterUrl
        self.seasons = seasons
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
