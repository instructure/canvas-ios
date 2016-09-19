//
//  NSData+SoLazy.swift
//  SoLazy
//
//  Created by Derrick Hathaway on 1/19/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension String {
    public func UTF8Data() throws -> NSData {
        guard let data = dataUsingEncoding(NSUTF8StringEncoding) else {
            let title = NSLocalizedString("Encoding Error", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.icanvas.SoLazy")!, value: "", comment: "Data encoding error title")
            let message = NSLocalizedString("There was a problem encoding UTF8 Data", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.icanvas.SoLazy")!, value: "", comment: "Data encoding error message")
            throw NSError(subdomain: "SoLazy", code: 0, title: title, description: message)
        }
        
        return data
    }
}


public func +=(lhs: NSMutableData, rhs: NSData) {
    lhs.appendData(rhs)
}
