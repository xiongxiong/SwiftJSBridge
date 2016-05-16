//
//  JSModel.swift
//  SwiftJSBridge
//
//  Created by 王继荣 on 5/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper

class JSModel: Mappable {

    var message: String = ""
    
    init(message: String) {
        self.message = message
    }
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        message <- map["message"]
    }
}
