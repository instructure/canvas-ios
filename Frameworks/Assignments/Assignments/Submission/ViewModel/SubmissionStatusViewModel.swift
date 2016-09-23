//
//  SubmissionStatusViewModel.swift
//  Assignments
//
//  Created by Nathan Lambson on 3/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import AssignmentKit

public class SubmissionStatusViewModel {
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
            
            let date = NSDateFormatter.MediumStyleDateTimeFormatter.stringFromDate(submittedAt)
            
            switch status {
            case .Submitted(.Late):
                return "\(Strings.submissionLate) \(date)"
            case .Submitted(.Excused):
                return "\(Strings.submissionExcused) \(date)"
            case .Submitted(.Normal): return date
            case .NotSubmitted, .NotAllowed: return ""
            }
        }
    }
    
    internal enum SubmittedStatus {
        case Excused, Late, Normal
    }
    
    internal enum SubmissionStatus: CustomStringConvertible {
        case Submitted(SubmittedStatus), NotSubmitted, NotAllowed
        
        var description: String {
            switch self {
            case .Submitted(_):
                return NSLocalizedString("Turned in!",
                    comment: "submission title for assignemnt that is submitted")
            case .NotSubmitted:
                return NSLocalizedString("Not Submitted",
                    comment: "submission title for assignment waiting user submission")
            case .NotAllowed:
                return NSLocalizedString("Submissions N/A",
                    comment: "submission title for assignment that doesn't support submissions")
            }
        }
        
        static func forAssignment(assignment: Assignment) -> SubmissionStatus {
            if assignment.hasSubmitted {
                if assignment.submissionExcused {
                    return .Submitted(.Excused)
                } else if assignment.submissionLate {
                    return .Submitted(.Late)
                }
                return .Submitted(.Normal)
            } else if !assignment.allowsSubmissions {
                return .NotAllowed
            }
            return .NotSubmitted
        }
    }
    
    struct Strings {
        
        static var submissionExcused: String {
            return NSLocalizedString("Excused", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "This assignment is excused")
        }
        
        static var submissionLate: String {
            return NSLocalizedString("Late", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "This assignment is late")
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
    case (.NotSubmitted, .NotSubmitted), (.NotAllowed, .NotAllowed):
        return true
    case let (.Submitted(status1), .Submitted(status2)):
        return status1 == status2
    default: return false
    }
}
