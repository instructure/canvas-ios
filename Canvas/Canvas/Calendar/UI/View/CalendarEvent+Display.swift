
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
import CalendarKit

extension CalendarEvent {

    public func dueText() -> String {
        guard let startAt = startAt, endAt = endAt else {
            return ""
        }

        if startAt.compare(endAt) == NSComparisonResult.OrderedSame {
            return "\(CalendarEvent.dueDateFormatter.stringFromDate(startAt))"
        }

        return "\(CalendarEvent.dueDateFormatter.stringFromDate(startAt)) - \(CalendarEvent.dueDateFormatter.stringFromDate(endAt))"
    }

    public func typeImage() -> UIImage {
        switch self.type {
        case .CalendarEvent:
            return (UIImage(named: "icon_calendar_event", inBundle: NSBundle(forClass: CalendarDayListCell.self), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        case .Assignment:
            return (UIImage(named: "icon_assignment", inBundle: NSBundle(forClass: CalendarDayListCell.self), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        case .Quiz:
            return (UIImage(named: "icon_quiz", inBundle: NSBundle(forClass: CalendarDayListCell.self), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        case .Discussion:
            return (UIImage(named: "icon_discussion", inBundle: NSBundle(forClass: CalendarDayListCell.self), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        default:
            return (UIImage(named: "icon_calendar_event", inBundle: NSBundle(forClass: CalendarDayListCell.self), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        }
    }
}