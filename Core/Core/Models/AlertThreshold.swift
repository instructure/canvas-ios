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

public enum AlertThresholdType: String, CaseIterable {
    case courseAnnouncement = "course_announcement"
    case institutionAnnouncement = "institution_announcement"
    case assignmentGradeHigh = "assignment_grade_high"
    case assignmentGradeLow = "assignment_grade_low"
    case assignmentMissing = "assignment_missing"
    case courseGradeHigh = "course_grade_high"
    case courseGradeLow = "course_grade_low"
}

public class AlertThreshold: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var observerID: String
    @NSManaged public var studentID: String
    @NSManaged public var threshold: String?
    @NSManaged public var typeRaw: String?
    public var type: AlertThresholdType? {
        get { return AlertThresholdType(rawValue: typeRaw ?? "") }
        set { typeRaw = newValue?.rawValue }
    }
}
