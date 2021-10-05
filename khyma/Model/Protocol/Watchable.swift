//
//  Watchable.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit

protocol Watchable {
    var _id: String? { get set }
    var categoryId: String? { get set }
    var genreId: String? { get set }
    var en_name: String? { get set }
    var ar_name: String? { get set }
    var posterImageUrl: String? { get set }
    var youtubeUrl: String? { get set }
    var seasons: [Season]? { get set }
    
//    var posterImageUrl: String? { get set }
//    var youtubeUrl: String? { get set }
}
