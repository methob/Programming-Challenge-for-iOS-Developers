//
//  DataAssets.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit
import ObjectMapper
import Foundation

class DataAssets: NSObject, Mappable {
    
    var assetsLocation: String?
    var medias: [Media]?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        assetsLocation <- map["assetsLocation"]
        medias <- map["objects"]
    }
    
}
