//
//  Text.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit
import ObjectMapper
import Foundation

class Text: NSObject, Mappable {

    var txt: String?
    var time: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        txt <- map["txt"]
        time <- map["time"]
    }
}
