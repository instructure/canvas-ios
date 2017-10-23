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
        case locked
        case ipFiltered
        case attemptLimitReached
        case undecided
        case other(String)
    }
    
    case notTakeable(reason: NotTakeableReason)
    case take
    case resume
    case retake
    case viewResults(URL)
    
    var takeable: Bool {
        return self == .take || self == .resume || self == .retake
    }
    
    var label: String {
        switch self {
        case .notTakeable:
            return ""
        case .take:
            return NSLocalizedString("Take Quiz", tableName: "Localizable", bundle: .core, value: "", comment: "Button for taking the quiz")
        case .resume:
            return NSLocalizedString("Resume Quiz", tableName: "Localizable", bundle: .core, value: "", comment: "button for resuming a quiz")
        case .retake:
            return NSLocalizedString("Retake Quiz", tableName: "Localizable", bundle: .core, value: "", comment: "button for retaking quiz")
        case .viewResults:
            return NSLocalizedString("View Results", tableName: "Localizable", bundle: .core, value: "", comment: "button for viewing quiz results")

        }
    }
}

func ==(lhs: Takeability, rhs: Takeability) -> Bool {
    switch (lhs, rhs) {
    case
    (.notTakeable(let lhsReason), .notTakeable(let rhsReason)):
        return lhsReason == rhsReason
    case
    (.take, .take),
    (.resume, .resume),
    (.retake, .retake),
    (.viewResults, .viewResults):
        return true
        
    default:
        return false
    }
}

func ==(lhs: Takeability.NotTakeableReason, rhs: Takeability.NotTakeableReason) -> Bool {
    switch (lhs, rhs) {
    case
    (.locked, .locked),
    (.ipFiltered, .ipFiltered),
    (.attemptLimitReached, .attemptLimitReached),
    (.undecided, .undecided),
    (.other, .other):
        return true
        
    default:
        return false
    }
}
