//
//  Season.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit
import SimpleAPI

typealias Episode = Video

class Season: NSObject, NSCoding, NSSecureCoding, Decodable {
    
    // Properties
    var name: String?
    var posterImageUrl: String?
    var youtubeUrl: String?
    var episodes: [Episode]?
    
    // NSSecureCoding
    static var supportsSecureCoding: Bool = true
    
    init(name: String, posterImageUrl: String, episodes: [Episode]) {
        self.name = name
        self.posterImageUrl = posterImageUrl
        self.episodes = episodes
    }
    
    func encode(with coder: NSCoder) {
        // encode Movie object into data
        coder.encode(name ?? "", forKey: "name")
        coder.encode(posterImageUrl ?? "", forKey: "posterImageUrl")
        coder.encode(episodes ?? [], forKey: "episodes")
    }
    
    required init?(coder: NSCoder) {
        // decode data into Movie object again
        self.name = coder.decodeObject(forKey: "name") as? String
        self.posterImageUrl = coder.decodeObject(forKey: "posterImageUrl") as? String
        self.episodes = coder.decodeObject(forKey: "episodes") as? [Episode]
    }
    
}
