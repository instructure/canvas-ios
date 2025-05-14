//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public enum ObserverAlertWorkflowState: String, Codable {
    case unread, read, dismissed
}

public final class ObserverAlert: NSManagedObject {
    @NSManaged public var actionDate: Date?
    @NSManaged public var alertTypeRaw: String
    @NSManaged public var contextType: String?
    @NSManaged public var contextID: String?
    @NSManaged public var htmlURL: URL?
    @NSManaged public var id: String
    @NSManaged public var observerID: String
    @NSManaged public var thresholdID: String
    @NSManaged public var title: String
    @NSManaged public var userID: String
    @NSManaged public var workflowStateRaw: String
    @NSManaged public var lockedForUser: Bool

    public var alertType: AlertThresholdType {
        get { AlertThresholdType(rawValue: alertTypeRaw) ?? .institutionAnnouncement }
        set { alertTypeRaw = newValue.rawValue }
    }

    public var workflowState: ObserverAlertWorkflowState {
        get { ObserverAlertWorkflowState(rawValue: workflowStateRaw) ?? .unread }
        set { workflowStateRaw = newValue.rawValue }
    }

    public var isUnread: Bool {
        workflowState == .unread
    }

    public var courseID: String? {
        switch alertType {
        case .courseGradeHigh, .courseGradeLow:
            return contextID
        case .assignmentGradeHigh, .assignmentGradeLow:
            guard
                let paths = htmlURL?.pathComponents,
                let courseIDIndex = paths.firstIndex(of: "courses")?.advanced(by: 1),
                let courseID = paths[safeIndex: courseIDIndex]
            else {
                return nil
            }

            return courseID
        default:
            return nil
        }
    }
}

extension ObserverAlert: WriteableModel {
    @discardableResult
    public static func save(_ item: APIObserverAlert, in context: NSManagedObjectContext) -> ObserverAlert {
        let model: ObserverAlert = context.first(where: #keyPath(ObserverAlert.id), equals: item.id.value) ?? context.insert()
        model.actionDate = item.action_date
        model.alertType = item.alert_type
        model.contextType = item.context_type
        model.contextID = item.context_id?.value
        model.htmlURL = item.html_url?.rawValue
        model.id = item.id.value
        model.observerID = item.observer_id.value
        model.thresholdID = item.observer_alert_threshold_id.value
        model.title = item.title
        model.userID = item.user_id.value
        model.workflowState = item.workflow_state
        model.lockedForUser = (item.locked_for_user == true)
        return model
    }
}
