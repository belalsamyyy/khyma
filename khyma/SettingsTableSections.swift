//
//  SettingsTableSections.swift
//  khyma
//
//  Created by Belal Samy on 24/09/2021.
//

import Foundation
import UIKit

enum SettingsTableSections: CaseIterable {
    case coins
    case theme
    case language
    
    var ui: (sectionTitle: String, sectionHeight: CGFloat) {
        switch self {
        case .coins:
            return (StringsKeys.coins.localized, 50)

        case .theme:
            return (StringsKeys.theme.localized, 60)

        case .language:
            return (StringsKeys.language.localized, 50)

        }
    }
}
