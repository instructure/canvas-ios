//
//  Alert+JSON.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import ObserverAlertKit
import Marshal
import SoPersistent

extension Alert {
    static var validJSON: JSONObject {
        let bundle = NSBundle(forClass: AlertTests.self)
        let path = bundle.pathForResource("valid_alert", ofType: "json")!
        return try! JSONParser.JSONObjectWithData(NSData(contentsOfFile: path)!)
    }
}
