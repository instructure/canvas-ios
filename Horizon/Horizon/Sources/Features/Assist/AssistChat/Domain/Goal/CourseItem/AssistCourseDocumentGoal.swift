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

import Combine
import Core
import Foundation

/// A goal for interacting with a course document in the Assist chat.
class AssistCourseDocumentGoal: AssistCourseItemGoal {
    // MARK: - Private Properties
    private var fileID: String? {
        state.fileID.value
    }
    private let initialPrompt = String(
        localized: "Can I answer any questions about this document for you?",
        bundle: .horizon
    )

    // MARK: - Initializer
    init(
        state: AssistState,
        cedar: DomainService = DomainService(.cedar)
    ) {
        super.init(
            state: state,
            initialPrompt: initialPrompt,
            cedar: cedar
        )
        sourceType = .attachment
    }

    // MARK: - Overrides
    /// If necessary, downloads the file and returns the page context.
    /// If we can't determine the format, we return an empty page context
    override
    var isRequested: Bool { courseID != nil && fileID != nil }

    override
    var sourceID: AnyPublisher<String?, Error> {
        state.sourceID
    }
}
