//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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