//
//  SeriesTableSections.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit

enum SeriesTableSections: CaseIterable {
    case popular
    case Movies
    case Series
    case Plays
    case anime
    
    var ui: (sectionTitle: String, sectionHeight: CGFloat) {
        switch self {
        
        case .popular:
            return (StringsKeys.popular.localized, 200)

        case .Movies:
            return (StringsKeys.movies.localized, 200)

        case .Series:
            return (StringsKeys.series.localized, 200)

        case .Plays:
            return (StringsKeys.plays.localized, 200)

        case .anime:
            return (StringsKeys.anime.localized, 200)

        }
    }

}
