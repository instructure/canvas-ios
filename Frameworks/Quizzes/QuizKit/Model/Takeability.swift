//
//  QuizTakeability.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 2/3/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

enum Takeability {
    
    enum NotTakeableReason {
        case Locked
        case IPFiltered
        case AttemptLimitReached
        case Undecided
        case Other(String)
    }
    
    case NotTakeable(reason: NotTakeableReason)
    case Take
    case Resume
    case Retake
    
    var takeable: Bool {
        return self == .Take || self == .Resume || self == .Retake
    }
    
    var label: String {
        switch self {
        case .NotTakeable:
            return ""
        case .Take:
            return NSLocalizedString("Take Quiz", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Button for taking the quiz")
        case .Resume:
            return NSLocalizedString("Resume Quiz", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "button for resuming a quiz")
        case .Retake:
            return NSLocalizedString("Retake Quiz", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "button for retaking quiz")
        }
    }
}

func ==(lhs: Takeability, rhs: Takeability) -> Bool {
    switch (lhs, rhs) {
    case
    (.NotTakeable(let lhsReason), .NotTakeable(let rhsReason)):
        return lhsReason == rhsReason
    case
    (.Take, .Take),
    (.Resume, .Resume),
    (.Retake, .Retake):
        return true
        
    default:
        return false
    }
}

func ==(lhs: Takeability.NotTakeableReason, rhs: Takeability.NotTakeableReason) -> Bool {
    switch (lhs, rhs) {
    case
    (.Locked, .Locked),
    (.IPFiltered, .IPFiltered),
    (.AttemptLimitReached, .AttemptLimitReached),
    (.Undecided, .Undecided),
    (.Other, .Other):
        return true
        
    default:
        return false
    }
}