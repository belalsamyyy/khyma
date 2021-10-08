//
//  Season.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit
import SimpleAPI

class Season: Model {
    // API
    static var endpoint: String!
    static var params: Params?
    static var headers: Headers?
    
    // Properties
    var _id: String?
    var en_name: String?
    var ar_name: String?
    var serieId: String?
}
