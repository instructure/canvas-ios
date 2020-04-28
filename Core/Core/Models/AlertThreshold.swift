//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import CoreData

public enum AlertThresholdType: String, CaseIterable, Codable {
    case courseGradeHigh = "course_grade_high"
    case courseGradeLow = "course_grade_low"
    case assignmentMissing = "assignment_missing"
    case assignmentGradeHigh = "assignment_grade_high"
    case assignmentGradeLow = "assignment_grade_low"
    case courseAnnouncement = "course_announcement"
    case institutionAnnouncement = "institution_announcement"

    public var name: String {
        switch self {
        case .courseGradeLow:
            return NSLocalizedString("Course grade below", bundle: .core, comment: "")
        case .courseGradeHigh:
            return NSLocalizedString("Course grade above", bundle: .core, comment: "")
        case .assignmentMissing:
            return NSLocalizedString("Assignment missing", bundle: .core, comment: "")
        case .assignmentGradeLow:
            return NSLocalizedString("Assignment grade below", bundle: .core, comment: "")
        case .assignmentGradeHigh:
            return NSLocalizedString("Assignment grade above", bundle: .core, comment: "")
        case .institutionAnnouncement:
            return NSLocalizedString("Institution announcements", bundle: .core, comment: "")
        case .courseAnnouncement:
            return NSLocalizedString("Course announcements", bundle: .core, comment: "")
        }
    }

    public var isPercent: Bool {
        switch self {
        case .assignmentGradeLow, .assignmentGradeHigh, .courseGradeLow, .courseGradeHigh:
            return true
        case .assignmentMissing, .courseAnnouncement, .institutionAnnouncement:
            return false
        }
    }
}

public final class AlertThreshold: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var observerID: String
    @NSManaged public var studentID: String
    @NSManaged public var threshold: NSNumber?
    @NSManaged public var typeRaw: String?
    public var type: AlertThresholdType? {
        get { return AlertThresholdType(rawValue: typeRaw ?? "") }
        set { typeRaw = newValue?.rawValue }
    }
    public var value: UInt? {
        get { threshold?.uintValue }
        set { threshold = newValue.map { NSNumber(value: $0) } }
    }
}
