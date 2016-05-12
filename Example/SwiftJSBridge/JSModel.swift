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

    var a: Int = 4
    var b: Double = 3.56789
    var c: Float = 1.0003
    var d: String = "Hello World!"
    var e: [String] = ["I am A.", "I am B"]
    var f: [String: String] = ["message": "I am message", "method": "I am method."]
    
    init() {
        
    }
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        a <- map["a"]
        b <- map["b"]
        c <- map["c"]
        d <- map["d"]
        e <- map["e"]
        f <- map["f"]
    }
}
