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
import UIKit
import ReactiveSwift
import AssignmentKit

open class SubmissionStatusViewModel {
    internal let assignment: Assignment
    
    internal let hasSubmitted: MutableProperty<Bool>
    internal let submittedStatus: MutableProperty<SubmissionStatus>
    internal let submittedDate = MutableProperty<String>("")
    
    public init(assignment: Assignment) {
        self.assignment = assignment
        self.submittedStatus = MutableProperty(SubmissionStatus.forAssignment(assignment))
        self.hasSubmitted = MutableProperty(assignment.hasSubmitted)
        self.submittedDate <~ submittedStatus.producer.map { status in
            guard let submittedAt = assignment.submittedAt else {
                return ""
            }
            
            let date = DateFormatter.MediumStyleDateTimeFormatter.string(from: submittedAt)
            
            switch status {
            case .submitted(.late):
                return "\(Strings.submissionLate) \(date)"
            case .submitted(.excused):
                return "\(Strings.submissionExcused) \(date)"
            case .submitted(.normal): return date
            case .notSubmitted, .notAllowed: return ""
            }
        }
    }
    
    internal enum SubmittedStatus {
        case excused, late, normal
    }
    
    internal enum SubmissionStatus: CustomStringConvertible {
        case submitted(SubmittedStatus), notSubmitted, notAllowed
        
        var description: String {
            switch self {
            case .submitted(_):
                return NSLocalizedString("Turned in!",
                    comment: "submission title for assignemnt that is submitted")
            case .notSubmitted:
                return NSLocalizedString("Not Submitted",
                    comment: "submission title for assignment waiting user submission")
            case .notAllowed:
                return NSLocalizedString("Submissions N/A",
                    comment: "submission title for assignment that doesn't support submissions")
            }
        }
        
        static func forAssignment(_ assignment: Assignment) -> SubmissionStatus {
            if assignment.hasSubmitted {
                if assignment.submissionExcused {
                    return .submitted(.excused)
                } else if assignment.submissionLate {
                    return .submitted(.late)
                }
                return .submitted(.normal)
            } else if !assignment.allowsSubmissions {
                return .notAllowed
            }
            return .notSubmitted
        }
    }
    
    struct Strings {
        
        static var submissionExcused: String {
            return NSLocalizedString("Excused", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "This assignment is excused")
        }
        
        static var submissionLate: String {
            return NSLocalizedString("Late", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "This assignment is late")
        }
        
    }
}

// MARK: - Equatable

extension SubmissionStatusViewModel: Equatable {}
public func ==(lhs: SubmissionStatusViewModel, rhs: SubmissionStatusViewModel) -> Bool {
    return lhs.hasSubmitted.value == rhs.hasSubmitted.value &&
        lhs.submittedDate.value == rhs.submittedDate.value &&
        lhs.submittedStatus.value == rhs.submittedStatus.value
}

extension SubmissionStatusViewModel.SubmissionStatus: Equatable {}
func ==(lhs: SubmissionStatusViewModel.SubmissionStatus, rhs: SubmissionStatusViewModel.SubmissionStatus) -> Bool {
    switch (lhs, rhs) {
    case (.notSubmitted, .notSubmitted), (.notAllowed, .notAllowed):
        return true
    case let (.submitted(status1), .submitted(status2)):
        return status1 == status2
    default: return false
    }
}
