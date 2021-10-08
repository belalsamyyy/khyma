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
    var posterImageUrl: String?
    var youtubeUrl: String?
    
    var genre: Genre?
    var category: Category?
    
    // just to confirm watchable
    var seasons: [Season]?
    
    // NSSecureCoding
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        // encode Movie object into data
        coder.encode(_id ?? "", forKey: "_id")
        coder.encode(categoryId ?? "", forKey: "categoryId")
        coder.encode(genreId ?? "", forKey: "genreId")
        coder.encode(en_name ?? "", forKey: "en_name")
        coder.encode(ar_name ?? "", forKey: "ar_name")
        coder.encode(posterImageUrl ?? "", forKey: "posterImageUrl")
        coder.encode(youtubeUrl ?? "", forKey: "youtubeUrl")
        coder.encode(seasons ?? [], forKey: "seasons")
        //
        //coder.encode(genre ?? "", forKey: "genre")
        //coder.encode(category ?? [], forKey: "category")
    }
    
    required init?(coder: NSCoder) {
        // decode data into Movie object again
        self._id = coder.decodeObject(forKey: "_id") as? String
        self.categoryId = coder.decodeObject(forKey: "categoryId") as? String
        self.genreId = coder.decodeObject(forKey: "genreId") as? String
        self.en_name = coder.decodeObject(forKey: "en_name") as? String
        self.ar_name = coder.decodeObject(forKey: "ar_name") as? String
        self.posterImageUrl = coder.decodeObject(forKey: "posterImageUrl") as? String
        self.youtubeUrl = coder.decodeObject(forKey: "youtubeUrl") as? String
        self.seasons = coder.decodeObject(forKey: "seasons") as? [Season]
        //
        //self.genre = coder.decodeObject(forKey: "genre") as? Genre
        //self.category = coder.decodeObject(forKey: "category") as? Category

    }
    
}



