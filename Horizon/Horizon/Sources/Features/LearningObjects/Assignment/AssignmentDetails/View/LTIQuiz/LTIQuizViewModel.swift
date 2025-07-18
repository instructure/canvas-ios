//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core
import Observation

@Observable
final class LTIQuizViewModel {
    // MARK: - Outputs

    private(set) var externalURL: URL?
    private(set) var isButtonLoaderVisible: Bool = false

    // MARK: - Inputs / Outputs
    
    var isLoaderVisible = true

    // MARK: - Dependancies

    private let courseID: String
    let name: String
    private let assignmentID: String
    private let isQuizLTI: Bool?
    private let externalToolContentID: String?
    private let moduleID: String
    private let itemID: String

    // MARK: - Init

    init(
        courseID: String,
        moduleID: String,
        itemID: String,
        name: String,
        assignmentID: String,
        isQuizLTI: Bool?,
        externalToolContentID: String?,
        environment: AppEnvironment = .shared
    ) {
        self.courseID = courseID
        self.moduleID = moduleID
        self.itemID = itemID
        self.name = name
        self.assignmentID = assignmentID
        self.isQuizLTI = isQuizLTI
        self.externalToolContentID = externalToolContentID
        let tools = LTITools(
            context: .course(courseID),
            id: externalToolContentID,
            launchType: .assessment,
            isQuizLTI: isQuizLTI,
            assignmentID: assignmentID,
            env: environment
        )
        tools.getSessionlessLaunch { [weak self] value in
            self?.externalURL = value?.url
        }
    }

    func refershCourse() {
        isButtonLoaderVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.isButtonLoaderVisible = false
            NotificationCenter.default.post(
                name: .moduleItemRequirementCompleted,
                object: ModuleItemAttributes(
                    courseID: self.courseID,
                    moduleID: self.moduleID,
                    itemID: self.itemID
                )
            )
        }
    }
}
