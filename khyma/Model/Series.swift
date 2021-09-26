//
//  Episode.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation

class Series: NSObject, Video, NSCoding, NSSecureCoding {
    var name: String?
    var posterImageUrl: String?
    var youtubeUrl: String?
    var seasons: [Season]?
    
    // NSSecureCoding
    static var supportsSecureCoding: Bool = true
    
    init(name: String, posterUrl: String) {
        self.name = name
        self.youtubeUrl = "https://www.youtube.com/watch?v=x_me3xsvDgk"
        self.posterImageUrl = posterUrl
    }
    
    func encode(with coder: NSCoder) {
        // encode Movie object into data
        coder.encode(name ?? "", forKey: "name")
        coder.encode(youtubeUrl ?? "", forKey: "youtubeUrl")
        coder.encode(posterImageUrl ?? "", forKey: "posterImageUrl")

    }
    
    required init?(coder: NSCoder) {
        // decode data into Movie object again
        self.name = coder.decodeObject(forKey: "name") as? String
        self.youtubeUrl = coder.decodeObject(forKey: "youtubeUrl") as? String
        self.posterImageUrl = coder.decodeObject(forKey: "posterImageUrl") as? String
    }
}
