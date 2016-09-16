//
//  CalendarEvent+Display.swift
//  Calendar
//
//  Created by Brandon Pluim on 4/25/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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