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

extension NSNotification.Name {
    public static var CompletedModuleItemRequirement = NSNotification.Name("com.instructure.core.notification.ModuleItemProgress")
    public static let SplitViewControllerWillChangeDisplayModeNotification = Notification.Name( "com.instructure.core.notification.splitview.willChangeDisplayMode")
    public static let quizRefresh = Notification.Name("com.instructure.core.notification.quizRefresh")
    public static let celebrateSubmission = Notification.Name("com.instructure.core.notification.celebrateSubmission")
    public static let showGradesOnDashboardDidChange = Notification.Name("com.instructure.core.notification.showGradesOnDashboardDidChange")
    public static let favoritesDidChange = Notification.Name("course-favorite-change")
    public static let windowUserInterfaceStyleDidChange = Notification.Name("com.instructure.core.notification.windowUserInterfaceStyleDidChange")
}

extension NotificationCenter {
    public func post(moduleItem: ModuleItemType, completedRequirement requirement: ModuleItemCompletionRequirement, courseID: String) {
        post(name: .CompletedModuleItemRequirement, object: nil, userInfo: ["requirement": requirement, "moduleItem": moduleItem, "courseID": courseID])
    }
}
