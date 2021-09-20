//
//  TableSections.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation
import UIKit

enum TableSections: CaseIterable {
    case continueWatching
    case popular
    case Movies
    case Series
    case Plays
    case games
    
    var ui: (sectionTitle: String, sectionHeight: CGFloat) {
        switch self {
        case .continueWatching:
            return ("Continue Watching", 200)
            
        case .popular:
            return ("Popular", 200)

        case .Movies:
            return ("Movies", 200)

        case .Series:
            return ("Series", 200)

        case .Plays:
            return ("Plays", 200)

        case .games:
            return ("Games", 200)

        }
    }

}
