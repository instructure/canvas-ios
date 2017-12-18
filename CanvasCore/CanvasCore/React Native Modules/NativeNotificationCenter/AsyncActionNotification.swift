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
}

private struct Action {
    let type: ActionType
    let result: Any

    init?(userInfo: [AnyHashable: Any]) {
        guard let result = userInfo["result"], let type = userInfo["type"] as? String, let actionType = ActionType(rawValue: type) else {
            return nil
        }

        self.type = actionType
        self.result = result
    }
}

private enum AsyncAction {
    case refreshCourses([JSONObject])

    init?(action: Action) {
        switch action.type {
        case .refreshCourses:
            if let result = action.result as? [JSONObject],
                result.count > 0,
                let courses: [JSONObject] = try? result[0] <| "data" {
                self = .refreshCourses(courses)
                return
            }
        }
        return nil
    }

    func syncProducer(_ session: Session) -> SignalProducer<Void, NSError> {
        switch self {
        case .refreshCourses(let courses):
            return attemptProducer { try session.enrollmentManagedObjectContext() }
                .flatMap(.latest) { Course.upsert(inContext: $0, jsonArray: Course.filter(rawCourses: courses)) }
                .map { _ in () }
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
