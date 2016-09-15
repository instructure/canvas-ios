//
//  NSError+QuizKit.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 4/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation


extension NSError {
    class func quizErrorWithMessage(message: String) -> NSError {
        return NSError(domain: "com.instructure.quizkit", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}