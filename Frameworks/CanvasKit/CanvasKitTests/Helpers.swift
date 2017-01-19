//
//  Helpers.swift
//  CanvasKit
//
//  Created by Rick Roberts on 7/3/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import Foundation

class Helpers: NSObject {
    
    class func loadJSONFixture(fixtureName: String) -> AnyObject? {
        
        
        var bundle = NSBundle(forClass: Helpers.self)
        var filePath = bundle.pathForResource(fixtureName, ofType: "json")
        println("filePath: \(filePath)")
        
        var data = NSData(contentsOfFile: filePath!)
        
        println("data = \(NSString(data: data!, encoding:NSUTF8StringEncoding))")
        var result: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
        
        println("result = \(result)")
        
        return result
    }
    
}