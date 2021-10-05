//
//  Response.swift
//  khyma
//
//  Created by Belal Samy on 05/10/2021.
//

import Foundation
import SimpleAPI

public struct SadekResponse: Model {
    //API
    public static var endpoint: String!
    public static var params: Params?
    public static var headers: Headers?
    
    // Properties
    var message: String?
}
