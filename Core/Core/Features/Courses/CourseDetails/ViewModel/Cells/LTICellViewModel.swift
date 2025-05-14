//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class LTICellViewModel: CourseDetailsCellViewModel {
    private let url: URL

    public init(tab: Tab, course: Course, url: URL) {
        self.url = url

        super.init(courseColor: course.color,
                   iconImage: tab.icon,
                   label: tab.label,
                   subtitle: nil,
                   accessoryIconType: .externalLink,
                   tabID: tab.id,
                   selectedCallback: nil)
    }

    public override func selected(environment: AppEnvironment, viewController: WeakViewController) {
        launchLTITool(env: environment, url: url, viewController: viewController)
    }

    private func launchLTITool(env: AppEnvironment, url: URL, viewController: WeakViewController) {
        LTITools.launch(
            context: nil,
            id: nil,
            url: url,
            launchType: nil,
            isQuizLTI: false,
            assignmentID: nil,
            from: viewController.value,
            env: env
        )
    }
}
