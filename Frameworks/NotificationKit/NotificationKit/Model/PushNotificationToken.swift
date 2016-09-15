//
//  PushNotificationToken.swift
//  NotificationKit
//
//  Created by Miles Wright on 6/15/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

public typealias PushNotificationToken = String
public extension String {
    public init(deviceTokenData: NSData) {
        // Token has form of <XXXX XXXXX.....XXXXX XXXX>, remove <> and spaces
        let tokenWithSpaces: NSString = deviceTokenData.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        let finalToken = tokenWithSpaces.stringByReplacingOccurrencesOfString(" ", withString: "")
        self.init(finalToken)
    }
}
