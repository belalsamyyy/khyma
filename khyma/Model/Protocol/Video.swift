//
//  Watchable.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit

protocol Video: Decodable {
    var name: String? { get set }
    var posterImageUrl: String? { get set }
    var youtubeUrl: String? { get set }
}
