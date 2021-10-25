//
//  Config.swift
//  khyma
//
//  Created by Belal Samy on 11/10/2021.
//

import Foundation
import UIKit
import SimpleAPI

struct Config: Model {
    //API
    static var endpoint: String!
    static var params: Params?
    static var headers: Headers?
    
    //Properties
    var _id: String?
    
    // every 30 mins ad feature
    var halfHourAdds: Bool?
    
    // update screen
    var updateScreen: Bool?
    var textArUpdateScreen: String?
    var textEnUpdateScreen: String?
    var linkUpdateScreen: String?
    var serverUrl: String?
}
