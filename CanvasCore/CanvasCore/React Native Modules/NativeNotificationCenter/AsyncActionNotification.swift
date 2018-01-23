//
//  AsyncActionNotification.swift
//  CanvasCore
//
//  Created by Nathan Armstrong on 12/15/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Marshal

private enum ActionType: String {
    case refreshCourses = "courses.refresh"
    case refreshCourseTabs = "courses.tabs.refresh"
    case updateCourseColor = "courses.updateColor"
    case toggleFavorite = "courses.toggleFavorite"
}

private struct Action {
    let type: ActionType
    let payload: JSONObject
    let result: Any

    init?(userInfo: [AnyHashable: Any]) {
        guard let payload = userInfo["payload"] as? JSONObject, let result = payload["result"], let type = userInfo["type"] as? String, let actionType = ActionType(rawValue: type) else {
            return nil
        }

        self.type = actionType
        self.payload = payload
        self.result = result
    }
}

private enum AsyncAction {
    case refreshCourses([JSONObject], JSONObject)
    case updateCourseColor(String, String)
    case toggleFavorite(String, Bool)
    case refreshCourseTabs(String, [JSONObject])
    
    init?(action: Action) {
        switch action.type {
        case .refreshCourses:
            if let result = action.result as? [JSONObject],
                result.count == 2,
                let courses: [JSONObject] = try? result[0] <| "data",
                let customColors: JSONObject = try? result[1] <| "data" {
                self = .refreshCourses(courses, customColors)
                return
            }
        case .updateCourseColor:
            if let courseID: String = try? action.payload <| "courseID",
                let color: String = try? action.payload <| "color" {
                self = .updateCourseColor(courseID, color)
                return
            }
        case .toggleFavorite:
            if let courseID: String = try? action.payload <| "courseID",
                let isFavorite: Bool = try? action.payload <| "markAsFavorite" {
                self = .toggleFavorite(courseID, isFavorite)
                return
            }
        case .refreshCourseTabs:
            if let courseID: String = try? action.payload <| "courseID",
                let result = action.result as? JSONObject,
                let tabs: [JSONObject] = try? result <| "data" {
                self = .refreshCourseTabs(courseID, tabs)
                return
            }
        }
        return nil
    }

    func syncProducer(_ session: Session) -> SignalProducer<Void, NSError> {
        switch self {
        case .refreshCourses(let courses, let customColors):
            let remote = SignalProducer<[JSONObject], NSError>(value: courses)
            let courses = attemptProducer { try session.enrollmentManagedObjectContext() }
                .flatMap(.latest) { Course.syncSignalProducer(inContext: $0, fetchRemote: remote) }
                .map { _ in () }

            let colors = attemptProducer { try session.enrollmentManagedObjectContext() }
                .flatMap(.latest) { Enrollment.writeFavoriteColors(customColors, inContext: $0) }
                .map { _ in () }

            return courses.concat(colors)
        case .updateCourseColor(let courseID, let hex):
            let contextID = ContextID(id: courseID, context: .course)
            guard let color = UIColor.colorFromHexString(hex) else { return .empty }
            return attemptProducer { try session.enrollmentManagedObjectContext() }
                .flatMap(.latest) { Enrollment.writeFavoriteColors([contextID: color], inContext: $0) }
        case .toggleFavorite(let courseID, let isFavorite):
            return attemptProducer {
                let context = try session.enrollmentManagedObjectContext()
                let contextID = ContextID(id: courseID, context: .course)
                let enrollment = try Course.findOne(contextID, inContext: context)
                enrollment?.isFavorite = isFavorite
                try context.save()
            }
        case .refreshCourseTabs(let courseID, let tabs):
            let contextID = ContextID(id: courseID, context: .course)
            let predicate = NSPredicate(format: "%K == %@", "rawContextID", contextID.canvasContextID)
            let remote = SignalProducer<[JSONObject], NSError>(value: tabs)
            let tabs   = attemptProducer { try session.enrollmentManagedObjectContext() }
                .flatMap(.latest) { Tab.syncSignalProducer(predicate, inContext: $0, fetchRemote: remote) }
                .map { _ in () }
            return tabs
        }
    }
}

public func startSyncingAsyncActions(_ session: Session) -> Disposable? {
    return NotificationCenter.default
        .reactive
        .notifications(forName: Notification.Name(rawValue: AsyncActionNotificationName))
        .map { $0.userInfo }
        .skipNil()
        .map(Action.init)
        .skipNil()
        .map(AsyncAction.init)
        .skipNil()
        .flatMap(.latest) { $0.syncProducer(session) }
        .observe(Observer())
}
