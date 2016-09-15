//
//  NSTimeInterval+MediaKit.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 9/3/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation



private let numberFormatter: NSNumberFormatter = {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.minimumIntegerDigits = 2
    return numberFormatter
    }()


extension NSTimeInterval {
    func formatted(includeSubSeconds: Bool = false) -> String {
        let effectiveTime = self < 0 ? -self : self
        
        let seconds = numberFormatter.stringFromNumber(Int(effectiveTime) % 60) ?? "!!"
        let justTheMinutes = Int(effectiveTime) / 60
        // if `justTheMinutes` is more than 99 just use the whole thing.
        let minutes = numberFormatter.stringFromNumber(justTheMinutes) ?? "\(justTheMinutes)"

        let subSeconds: String
        if includeSubSeconds {
            let tenthOfASecond = Int((effectiveTime - trunc(effectiveTime)) * 10)
            subSeconds = ".\(tenthOfASecond)"
        } else {
            subSeconds = ""
        }
        
        return "\(minutes):\(seconds)\(subSeconds)"
    }
}