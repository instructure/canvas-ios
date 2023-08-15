//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI

public extension APIPlannable {

    var k5ScheduleIcon: Image {
        switch plannableType {
        case .announcement:
            return Image.announcementLine
        case .assignment:
            return Image.assignmentLine
        case .calendar_event:
            return Image.calendarTab
        case .discussion_topic:
            return Image.discussionLine
        case .planner_note:
            return Image.noteLine
        default:
            return Image.addLine
        }
    }

    var k5SchedulePoints: String? { Self.k5SchedulePoints(from: pointsPossible) }

    static func k5SchedulePoints(from points: Double?) -> String? {
        guard let points = points else { return nil }
        let pointsTemplate = NSLocalizedString("g_pts", bundle: .core, comment: "")
        return String.localizedStringWithFormat(pointsTemplate, points)
    }

    var k5ScheduleDueText: String {
        if self.plannable?.all_day == true {
            return NSLocalizedString("All Day", comment: "")
        } else if let start = self.plannable?.start_at, let end = self.plannable?.end_at {
            return start.timeIntervalString(to: end)
        } else if plannableType == .announcement {
            return plannable_date.timeString
        } else {
            let dueTemplate = NSLocalizedString("Due: %@", bundle: .core, comment: "")
            return String.localizedStringWithFormat(dueTemplate, plannable_date.timeString)
        }
    }

    var k5ScheduleLabels: [(text: String, color: Color)] {
        guard let submissionStates = submissions?.value1 else { return [] }
        var labels: [(text: String, color: Color)] = []

        if submissionStates.graded == true {
            labels.append((text: NSLocalizedString("Graded", comment: ""), color: .ash))
        }
        if submissionStates.late == true {
            labels.append((text: NSLocalizedString("Late", comment: ""), color: .crimson))
        }
        if submissionStates.has_feedback == true {
            labels.append((text: NSLocalizedString("Feedback", comment: ""), color: .ash))
        }
        if submissionStates.redo_request == true {
            labels.append((text: NSLocalizedString("Redo", comment: ""), color: .crimson))
        }
        if submissionStates.missing == true {
            labels.append((text: NSLocalizedString("Missing", comment: ""), color: .crimson))
        }
        if submissionStates.submitted == true && submissionStates.late == false {
            labels.append((text: NSLocalizedString("Submitted", comment: ""), color: .ash))
        }

        return labels
    }

    func k5ScheduleSubject(courseInfoByCourseIDs: [String: (color: Color, image: URL?, isHomeroom: Bool, shouldHideQuantitativeData: Bool)]) -> K5ScheduleSubject {
        let name: String = {
            if plannableType == .calendar_event {
                return NSLocalizedString("To Do", comment: "")
            } else {
                return context_name ?? NSLocalizedString("To Do", comment: "")
            }
        }()
        let color: Color = {
            if let courseID = course_id?.value, let color = courseInfoByCourseIDs[courseID]?.color {
                return color
            } else {
                return Color(Brand.shared.primary.cgColor)
            }
        }()
        let route: URL? = {
            let isHomeroom: Bool = {
                guard let courseID = course_id?.value else {
                    return false
                }
                return courseInfoByCourseIDs[courseID]?.isHomeroom ?? false
            }()

            guard let context = context, context.contextType != .user, !isHomeroom  else { return nil }
            return URL(string: context.pathComponent)
        }()
        let image: URL? = {
            guard let courseID = course_id?.value else { return nil }
            return courseInfoByCourseIDs[courseID]?.image
        }()
        let shouldHideQuantitativeData: Bool = {
            guard let courseID = course_id?.value else { return false }
            return courseInfoByCourseIDs[courseID]?.shouldHideQuantitativeData == true
        }()

        return K5ScheduleSubject(name: name, color: color, image: image, route: route, shouldHideQuantitativeData: shouldHideQuantitativeData)
    }
}
