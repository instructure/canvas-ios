//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import CanvasCore

private struct Submission {

    fileprivate static var percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    static let gradeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    struct Status: OptionSet {
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
    let type: SubmissionTypes
    let gradePostedAt: Date?
    let missing: Bool

    var onPaper: Bool {
        return type.contains(.onPaper)
    }

    var displayText: String {
        if status.contains(.Excused) {
            return NSLocalizedString("Excused", comment: "")
        }

        if status.contains(.Graded), let postedAt = gradePostedAt, postedAt < Date() {
            guard let currentScore = currentScore else {
                if status.contains(.Late) {
                    return NSLocalizedString("Late", comment: "")
                } else if status.contains(.Submitted) {
                    return NSLocalizedString("Submitted", comment: "")
                } else {
                    return NSLocalizedString("Missing", comment: "")
                }
            }
            let score = currentScore.doubleValue
            let pointsPossible = self.pointsPossible?.doubleValue ?? 0.0
            var grade = Submission.percentFormatter.string(from: NSNumber(value: score / pointsPossible))
            if (score != 0 && pointsPossible == 0) {
                grade = String(format: "(%g/%g)", score, pointsPossible)
            } else if (score == 0 && pointsPossible == 0) {
                grade = "(0/0)"
            }

            if status.contains(.Late) {
                return String(format: NSLocalizedString("Late: %@", comment: ""), grade ?? "")
            } else if missing {
                return String(format: NSLocalizedString("Missing: %@", comment: ""), grade ?? "")
            } else {
                return String(format: NSLocalizedString("Submitted: %@", comment: ""), grade ?? "")
            }
        } else if status.contains(.Submitted) {
            if status.contains(.Late) {
                return NSLocalizedString("Late", comment: "")
            } else {
                return NSLocalizedString("Submitted", comment: "")
            }
        } else {
            if missing {
                return NSLocalizedString("Missing", comment: "")
            } else if onPaper {
                return NSLocalizedString("In-Class", comment: "")
            } else {
                return ""
            }
        }
    }

    var displayVerboseText: String {
        if status.contains(.Graded), let postedAt = gradePostedAt, postedAt < Date() {
            guard let pointsPossible = pointsPossible, let score = currentScore else { return self.displayText }
            let percentage = pointsPossible != 0 ? Submission.percentFormatter.string(from: NSNumber(value: score.doubleValue/pointsPossible.doubleValue)) : ""

            if status.contains(.Late) {
                return String(format: NSLocalizedString("Late: %@ (%@/%@)", comment: ""), percentage ?? "", score, pointsPossible)
            } else if missing {
                return String(format: NSLocalizedString("Missing: %@ (%@/%@)", comment: ""), percentage ?? "", score, pointsPossible)
            } else {
                return String(format: NSLocalizedString("Submitted: %@ (%@/%@)", comment: ""), percentage ?? "", Submission.gradeNumberFormatter.string(from: score) ?? score, pointsPossible)
            }
        } else if status.contains(.Submitted) {
            return displayText
        } else {
            if missing {
                guard let pointsPossible = pointsPossible else { return self.displayText }
                return String(format: NSLocalizedString("Missing: (-/%@)", comment: ""), pointsPossible)
            } else if onPaper {
                return NSLocalizedString("In-Class", comment: "")
            } else {
                return ""
            }
        }
    }

    var displayImage: UIImage? {
        if status.contains(.Late) && !onPaper {
            return UIImage(named: "icon_alert_fill")
        }

        if (status.contains(.Graded) && !missing) || status.contains(.Submitted) || status.contains(.Excused) {
            return UIImage(named: "icon_checkmark_fill")
        }

        if missing {
            return UIImage(named: "icon_alert_fill")
        }

        return nil
    }

    var displayColor: UIColor {
        if status.contains(.Late) {
            return UIColor.named(.textWarning)
        }

        if (status.contains(.Graded) && !missing) || status.contains(.Submitted) || status.contains(.Excused) {
            return UIColor.named(.textInfo)
        }

        if missing {
            return UIColor.named(.textDanger)
        }

        if onPaper {
            return UIColor.named(.textSuccess)
        }

        return UIColor.named(.textDark)
    }
}

extension CalendarEvent {

    fileprivate var submission: Submission? {
        guard type != .calendarEvent else { return nil }
        return Submission(status: Submission.Status(rawValue: rawStatus),
                          currentGrade: currentGrade,
                          currentScore: currentScore,
                          pointsPossible: pointsPossible,
                          pastEndDate: pastEndDate,
                          type: submissionTypes,
                          gradePostedAt: gradePostedAt,
                          missing: submissionMissing)
    }

    @objc var submittedText: String {
        return submission?.displayText ?? ""
    }

    @objc var submittedVerboseText: String {
        return submission?.displayVerboseText ?? ""
    }

    @objc var submittedImage: UIImage? {
        return submission?.displayImage ?? type.image()
    }

    @objc var submittedColor: UIColor {
        return submission?.displayColor ?? UIColor.named(.textDark)
    }
}

extension Assignment {

    fileprivate var overdue: Bool {
        if let dueDate = due {
            return Date().compare(dueDate) == ComparisonResult.orderedDescending
        } else {
            return false
        }
    }

    fileprivate var submission: Submission {
        return Submission(status: Submission.Status(rawValue: rawStatus),
                          currentGrade: currentGrade,
                          currentScore: currentScore,
                          pointsPossible: NSNumber(value: pointsPossible),
                          pastEndDate: overdue,
                          type: submissionTypes,
                          gradePostedAt: gradePostedAt,
                          missing: submissionMissing)
    }

    @objc var submittedText: String {
        return submission.displayText
    }

    @objc var submittedVerboseText: String {
        return submission.displayVerboseText
    }

    @objc var submittedImage: UIImage? {
        return submission.displayImage
    }

    @objc var submittedColor: UIColor {
        return submission.displayColor
    }
}
