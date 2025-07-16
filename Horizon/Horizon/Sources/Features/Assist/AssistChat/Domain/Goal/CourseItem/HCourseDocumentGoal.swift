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
class HCourseDocumentGoal: HCourseItemGoal {
    // MARK: - Private Properties
    private var fileID: String? {
        environment.fileID.value
    }
    private let initialPrompt = String(
        localized: "Can I answer any questions about this document for you?",
        bundle: .horizon
    )

    // MARK: - Dependencies
    private let downloadFileInteractor: DownloadFileInteractor

    // MARK: - Initializer
    init(
        environment: AssistDataEnvironment,
        downloadFileInteractor: DownloadFileInteractor,
        cedar: DomainService = DomainService(.cedar)
    ) {
        self.downloadFileInteractor = downloadFileInteractor
        super.init(
            initialPrompt: initialPrompt,
            environment: environment,
            cedar: cedar
        )
    }

    // MARK: - Overrides
    /// If necessary, downloads the file and returns the page context.
    /// If we can't determine the format, we return an empty page context
    override
    var document: AnyPublisher<CedarAnswerPromptMutation.DocumentInput?, Error> {
        guard let courseID = courseID, let fileID = fileID else {
            return Just<CedarAnswerPromptMutation.DocumentInput?>(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return ReactiveStore(useCase: GetFile(context: .course(courseID), fileID: fileID))
            .getEntities()
            .map { files in files.first }
            .flatMap { [weak self] (file: File?) in
                guard let self = self,
                      let file = file,
                      let format = AssistChatDocumentType.from(mimeType: file.contentType) else {
                    return Just<CedarAnswerPromptMutation.DocumentInput?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return self.downloadFileInteractor
                    .download(fileID: fileID)
                    .map { try? Data(contentsOf: $0) }
                    .map { $0?.base64EncodedString() }
                    .compactMap { (base64String: String?) in
                        guard let base64String = base64String else {
                            return nil
                        }
                        return CedarAnswerPromptMutation.DocumentInput(
                            format: format,
                            base64Source: base64String
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    override
    func isRequested() -> Bool { courseID != nil && fileID != nil }

    override
    var options: [Option] {
        Option.allCases.filter { $0 != .Quiz }
    }
}
