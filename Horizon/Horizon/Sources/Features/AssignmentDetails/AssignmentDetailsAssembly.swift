//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import Foundation

final class AssignmentDetailsAssembly {
    static func makeViewModel(
        courseID: String,
        assignmentID: String
    ) -> AssignmentDetailsViewModel {
        let uploadManager = HUploadFileManagerLive(
            uploadManager: .shared,
            assignmentID: assignmentID,
            courseID: courseID
        )
        let interactor = AssignmentInteractorLive(
            courseID: courseID,
            assignmentID: assignmentID,
            uploadManager: uploadManager,
            appEnvironment: .shared
        )
        let router = AppEnvironment.shared.router
        return AssignmentDetailsViewModel(interactor: interactor, router: router)
    }

    static func makeViewController(
        courseID: String,
        assignmentID: String
    ) -> UIViewController {
        CoreHostingController(AssignmentDetails(viewModel: makeViewModel(courseID: courseID, assignmentID: assignmentID)))
    }

#if DEBUG
    static func makePreview() -> AssignmentDetails {
        let interactor = AssignmentInteractorPreview()
        let router = AppEnvironment.shared.router
        let viewModel = AssignmentDetailsViewModel(interactor: interactor, router: router)
        return AssignmentDetails(viewModel: viewModel)
    }

    static func makeAssignmentSubmissionViewModel() -> AssignmentDetailsViewModel {
        let interactor = AssignmentInteractorPreview()
        let router = AppEnvironment.shared.router
        return AssignmentDetailsViewModel(interactor: interactor, router: router)
    }

#endif
}
