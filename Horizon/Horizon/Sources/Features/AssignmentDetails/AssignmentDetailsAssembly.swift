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
import SwiftUI
import Foundation
import Combine

final class AssignmentDetailsAssembly {
    static func makeViewModel(
        courseID: String,
        assignmentID: String,
        onTapAssignmentOptions: PassthroughSubject<Void, Never>,
        didLoadAttemptCount: @escaping (String?) -> Void
    ) -> AssignmentDetailsViewModel {
        let uploadManager = HUploadFileManagerLive(
            uploadManager: .shared,
            assignmentID: assignmentID,
            courseID: courseID
        )

        let interactor = AssignmentInteractorLive(
            courseID: courseID,
            assignmentID: assignmentID,
            userID: AppEnvironment.shared.currentSession?.userID ?? "",
            uploadManager: uploadManager,
            appEnvironment: .shared
        )
        let userDefaults = AppEnvironment.shared.userDefaults
        let textEntryInteractor = AssignmentTextEntryInteractorLive(
            courseID: courseID,
            assignmentID: assignmentID,
            userDefaults: userDefaults
        )
        let router = AppEnvironment.shared.router

        return AssignmentDetailsViewModel(
            interactor: interactor,
            textEntryInteractor: textEntryInteractor,
            router: router,
            courseID: courseID,
            assignmentID: assignmentID,
            onTapAssignmentOptions: onTapAssignmentOptions,
            didLoadAttemptCount: didLoadAttemptCount
        )
    }

    static func makeView(
        courseID: String,
        assignmentID: String,
        onTapAssignmentOptions: PassthroughSubject<Void, Never>,
        didLoadAttemptCount: @escaping (String?) -> Void
    ) -> AssignmentDetails {
        AssignmentDetails(
            viewModel: makeViewModel(
                courseID: courseID,
                assignmentID: assignmentID,
                onTapAssignmentOptions: onTapAssignmentOptions,
                didLoadAttemptCount: didLoadAttemptCount
            )
        )
    }

#if DEBUG
    static func makePreview() -> AssignmentDetails {
        return AssignmentDetails(viewModel: makePreviewViewModel())
    }

    static func makePreviewViewModel() -> AssignmentDetailsViewModel {
        let interactor = AssignmentInteractorPreview()
        let assignmentTextEntryInteractor = AssignmentTextEntryInteractorLive(
            courseID: "courseID",
            assignmentID: "assignmentID",
            userDefaults: AppEnvironment.shared.userDefaults
        )
        return AssignmentDetailsViewModel(
            interactor: interactor,
            textEntryInteractor: assignmentTextEntryInteractor,
            router: AppEnvironment.shared.router,
            courseID: "1",
            assignmentID: "assignmentID",
            onTapAssignmentOptions: .init()
        ) { _ in}

    }
#endif
}
