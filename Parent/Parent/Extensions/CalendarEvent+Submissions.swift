//
//  CalendarEvent+Submissions.swift
//  Parent
//
//  Created by Brandon Pluim on 3/17/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import CalendarKit
import AssignmentKit

private struct Submission {

    private static var percentFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .PercentStyle
        return formatter
    }()

    struct Status: OptionSetType {
        let rawValue: Int64
        init(rawValue: Int64) { self.rawValue = rawValue}

        static let Late      = Status(rawValue: 1)
        static let Excused   = Status(rawValue: 2)
        static let Submitted = Status(rawValue: 4)
        static let Graded    = Status(rawValue: 8)
        static let PendingReview = Status(rawValue: 16)
        static let Unsubmitted = Status(rawValue: 32)
    }

    let status: Status
    let currentGrade: String?
    let currentScore: NSNumber?
    let pointsPossible: NSNumber?
    let pastEndDate: Bool
    let onPaper: Bool
    let muted: Bool

    var displayText: String {
        if status.contains(.Excused) {
            return NSLocalizedString("Excused", comment: "")
        }

        if status.contains(.Graded) && !muted {
            guard let currentScore = currentScore else {
                if status.contains(.Late) {
                    return NSLocalizedString("Late", comment: "")
                } else {
                    return NSLocalizedString("Submitted", comment: "")
                }
            }
            let score = currentScore.doubleValue
            let pointsPossible = self.pointsPossible?.doubleValue ?? 0.0
            let percentage = Submission.percentFormatter.stringFromNumber(score / pointsPossible)
            if status.contains(.Late) {
                return String(format: NSLocalizedString("Late: %@", comment: ""), percentage ?? "")
            } else {
                return String(format: NSLocalizedString("Submitted: %@", comment: ""), percentage ?? "")
            }
        } else if status.contains(.Submitted) {
            if status.contains(.Late) {
                return NSLocalizedString("Late", comment: "")
            } else {
                return NSLocalizedString("Submitted", comment: "")
            }
        } else {
            if onPaper {
                return NSLocalizedString("In-Class", comment: "")
            } else if pastEndDate {
                return NSLocalizedString("Missing", comment: "")
            } else {
                return ""
            }
        }
    }

    var displayVerboseText: String {
        if status.contains(.Graded) && !muted {
            guard let pointsPossible = pointsPossible, score = currentScore else { return self.displayText }
            let percentage = Submission.percentFormatter.stringFromNumber(score.doubleValue/pointsPossible.doubleValue)
            if status.contains(.Late) {
                return String(format: NSLocalizedString("Late: %@ (%@/%@)", comment: ""), percentage ?? "", score, pointsPossible)
            } else {
                return String(format: NSLocalizedString("Submitted: %@ (%@/%@)", comment: ""), percentage ?? "", score, pointsPossible)
            }
        } else if status.contains(.Submitted) {
            return displayText
        } else {
            if onPaper {
                return NSLocalizedString("In-Class", comment: "")
            } else if pastEndDate {
                guard let pointsPossible = pointsPossible else { return self.displayText }
                return String(format: NSLocalizedString("Missing: (-/%@)", comment: ""), pointsPossible)
            } else {
                return ""
            }
        }
    }

    var displayImage: UIImage? {
        if status.contains(.Late) && !onPaper {
            return UIImage(named: "icon_alert_fill")
        }

        if status.contains(.Graded) || status.contains(.Submitted) || status.contains(.Excused) {
            return UIImage(named: "icon_checkmark_fill")
        }

        if pastEndDate && !onPaper {
            return UIImage(named: "icon_alert_fill")
        }

        return nil
    }

    var displayColor: UIColor {
        if status.contains(.Late) {
            return UIColor.parentYellowColor()
        }
        
        if status.contains(.Graded) || status.contains(.Submitted) || status.contains(.Excused) {
            return UIColor.parentBlueColor()
        }

        if onPaper {
            return UIColor.parentGreenColor()
        }

        if pastEndDate {
            return UIColor.parentRedColor()
        }

        return UIColor.parentLightGreyColor()
    }
}

extension CalendarEvent {

    private var submission: Submission? {
        guard type != .CalendarEvent else { return nil }
        return Submission(status: Submission.Status(rawValue: rawStatus), currentGrade: currentGrade, currentScore: currentScore, pointsPossible: pointsPossible, pastEndDate: pastEndDate, onPaper: submissionTypes.contains(.OnPaper), muted: muted)
    }

    var submittedText: String {
        return submission?.displayText ?? ""
    }

    var submittedVerboseText: String {
        return submission?.displayVerboseText ?? ""
    }

    var submittedImage: UIImage? {
        return submission?.displayImage ?? type.image()
    }

    var submittedColor: UIColor {
        return submission?.displayColor ?? UIColor.parentLightGreyColor()
    }
}

extension Assignment {

    private var overdue: Bool {
        if let dueDate = due {
            return NSDate().compare(dueDate) == NSComparisonResult.OrderedDescending
        } else {
            return false
        }
    }

    private var submission: Submission {
        return Submission(status: Submission.Status(rawValue: rawStatus), currentGrade: currentGrade, currentScore: currentScore, pointsPossible: NSNumber(double: pointsPossible), pastEndDate: overdue, onPaper: submissionTypes.contains(.OnPaper), muted: muted)
    }

    var submittedText: String {
        return submission.displayText
    }

    var submittedVerboseText: String {
        return submission.displayVerboseText
    }

    var submittedImage: UIImage? {
        return submission.displayImage
    }

    var submittedColor: UIColor {
        return submission.displayColor
    }
}
