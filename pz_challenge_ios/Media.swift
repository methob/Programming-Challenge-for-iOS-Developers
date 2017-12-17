//
//  Media.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit
import Foundation
import ObjectMapper


final class Media: NSObject, Mappable {
    
    var name : String?
    var audio : String?
    var image : String?
    var video : String?
    var showProgress: Bool = false
    var txts: [Text] = []
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        name <- map["name"]
        audio <- map["sg"]
        image <- map["im"]
        video <- map["bg"]
        txts <- map["txts"]
    }
}
