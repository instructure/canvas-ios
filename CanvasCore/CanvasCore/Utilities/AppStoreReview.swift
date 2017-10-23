//
//  SKStoreReviewController+SoLazy.swift
//  SoLazy
//
//  Created by Layne Moseley on 9/11/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import StoreKit

public class AppStoreReview {
    
    public class func requestReview() {
        let countKey = "InstLaunchCount"
        let dateKey = "InstLastReviewRequestKey"
        let date = UserDefaults.standard.value(forKey: dateKey) as? Date
        var count = UserDefaults.standard.integer(forKey: countKey)
        var dateCheck = true
        if let d = date {
            let calendar = Calendar.current
            let comps = calendar.dateComponents([Calendar.Component.day], from: d, to: Date())
            if let day = comps.day {
                dateCheck = day > 30
            }
        }
        count += 1
        if (count > 10 && dateCheck) {
            if #available(iOS 10.3, *) {
                #if RELEASE
                SKStoreReviewController.requestReview()
                #endif
                
                let now = Date()
                UserDefaults.standard.set(now, forKey: dateKey)
            }
        }
        
        UserDefaults.standard.set(count, forKey: countKey)
    }
}
