//
//  Movie.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation
import UIKit
import SimpleAPI

typealias Movie = Video
typealias Play = Video
typealias Episode = Video

class Video: NSObject, Watchable, NSCoding, NSSecureCoding, Model {
    // API
    static var endpoint: String!
    static var params: Params?
    static var headers: Headers? = ["Content-type": "application/json"]
    
    // properties
    var _id: String?
    var categoryId: String?
    var genreId: String?
    var en_name: String?
    var ar_name: String?
    var posterImageLink: String?
    var youtubeUrl: String?
    var price: Int?
    var frequency: Int?
    
    // NSSecureCoding
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        // encode Movie object into data
        coder.encode(_id ?? "", forKey: "_id")
        coder.encode(categoryId ?? "", forKey: "categoryId")
        coder.encode(genreId ?? "", forKey: "genreId")
        coder.encode(en_name ?? "", forKey: "en_name")
        coder.encode(ar_name ?? "", forKey: "ar_name")
        coder.encode(posterImageLink ?? "", forKey: "posterImageUrl")
        coder.encode(youtubeUrl ?? "", forKey: "youtubeUrl")
        coder.encode(price ?? "", forKey: "price")
        coder.encode(frequency ?? "", forKey: "frequency")
    }
    
    required init?(coder: NSCoder) {
        // decode data into Movie object again
        self._id = coder.decodeObject(forKey: "_id") as? String
        self.categoryId = coder.decodeObject(forKey: "categoryId") as? String
        self.genreId = coder.decodeObject(forKey: "genreId") as? String
        self.en_name = coder.decodeObject(forKey: "en_name") as? String
        self.ar_name = coder.decodeObject(forKey: "ar_name") as? String
        self.posterImageLink = coder.decodeObject(forKey: "posterImageUrl") as? String
        self.youtubeUrl = coder.decodeObject(forKey: "youtubeUrl") as? String
        self.price = coder.decodeObject(forKey: "price") as? Int
        self.frequency = coder.decodeObject(forKey: "frequency") as? Int
    }
}



