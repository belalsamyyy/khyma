//
//  Category.swift
//  khyma
//
//  Created by Belal Samy on 06/10/2021.
//

import Foundation
import UIKit
import SimpleAPI

struct Category: Model {
    //API
    static var endpoint: String!
    static var params: Params?
    static var headers: Headers?
    
    //Properties
    var _id: String?
    var en_name: String?
    var ar_name: String?
}
