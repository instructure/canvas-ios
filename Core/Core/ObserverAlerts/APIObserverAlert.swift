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

// Not documented
public struct APIObserverAlert: Codable {
    let action_date: Date?
    let alert_type: AlertThresholdType
    let context_type: String?
    let context_id: ID?
    let html_url: APIURL?
    let id: ID
    let observer_id: ID
    let observer_alert_threshold_id: ID
    let title: String
    let user_id: ID
    let workflow_state: ObserverAlertWorkflowState
    let locked_for_user: Bool?
}

#if DEBUG
extension APIObserverAlert {
    public static func make(
        action_date: Date? = Clock.now,
        alert_type: AlertThresholdType = .institutionAnnouncement,
        context_type: String? = "Course",
        context_id: String? = "1",
        html_url: URL? = URL(string: "/accounts/self/account_notifications/1"),
        id: String = "1",
        observer_id: String = "1",
        observer_alert_threshold_id: String = "1",
        title: String = "Announcement",
        user_id: String = "2",
        workflow_state: ObserverAlertWorkflowState = .unread,
        locked_for_user: Bool? = false
    ) -> APIObserverAlert {
        return APIObserverAlert(
            action_date: action_date,
            alert_type: alert_type,
            context_type: context_type,
            context_id: context_id.map { ID($0) },
            html_url: APIURL(rawValue: html_url),
            id: ID(id),
            observer_id: ID(observer_id),
            observer_alert_threshold_id: ID(observer_alert_threshold_id),
            title: title,
            user_id: ID(user_id),
            workflow_state: workflow_state,
            locked_for_user: locked_for_user
        )
    }
}
#endif
