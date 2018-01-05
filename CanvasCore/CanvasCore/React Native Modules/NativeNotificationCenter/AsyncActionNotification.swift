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
    case updateCourseColor = "courses.updateColor"
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
        }
        return nil
    }

    func syncProducer(_ session: Session) -> SignalProducer<Void, NSError> {
        switch self {
        case .refreshCourses(let courses, let customColors):
            let courses = attemptProducer { try session.enrollmentManagedObjectContext() }
                .flatMap(.latest) { Course.upsert(inContext: $0.syncContext, jsonArray: Course.filter(rawCourses: courses)).observe(on: ManagedObjectContextScheduler(context: $0.syncContext)) }
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
