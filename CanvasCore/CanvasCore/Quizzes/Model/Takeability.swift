//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
